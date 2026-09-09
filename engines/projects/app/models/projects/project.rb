# A named body of work, and the tag that gathers it.
#
# A project holds nothing. It is a name, a tag and a place in a tree, and what
# it shows is whatever the tools around it answer when asked for that tag —
# which means a palette joins a project by being tagged in Pandatone, and
# leaves it the same way. There is no second list to keep in step.
#
# The rule that puts something in one place rather than four:
#
#   An item lands on the deepest project whose tags it all carries.
#
# So under #bobbymeyerdotcom with a subproject #2026summer, a palette tagged
# both is the subproject's and is not repeated at the top; one tagged only
# #bobbymeyerdotcom stays at the top; and one tagged only #2026summer is in
# neither, because a subproject narrows a project rather than standing beside
# it.
module Projects
  class Project < ApplicationRecord
    # A tag is one word, downcased, matched whole — the same thing a tag is in
    # every tool this gathers from. Two words would not match anything.
    TAG = /\A[^\s,]+\z/

    # The tag is the address: /projects/2026summer. These two are the engine's
    # own addresses under the same mount, so a project may not take them.
    RESERVED = %w[ new api ].freeze

    belongs_to :parent, class_name: "Projects::Project", optional: true, inverse_of: :children
    # Nothing goes while something still points at it: a subproject whose
    # parent has gone has lost the tags that placed it.
    has_many :children, -> { order(:name) }, class_name: "Projects::Project",
      foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error

    validates :name, presence: true
    validates :tag, presence: true
    # allow_blank on its own line, and never on the same call as the presence
    # rule: it applies to every validator in the call, and a blank tag would
    # then be allowed by the one rule that exists to refuse it.
    validates :tag, uniqueness: true, allow_blank: true,
      format: { with: TAG, message: "is one word, with no spaces or commas" },
      exclusion: { in: RESERVED, message: "is an address this tool already uses" }
    validate :parent_is_somewhere_else

    before_validation :normalize_tag

    scope :roots, -> { where(parent_id: nil).order(:name) }
    scope :name_matching, ->(q) { q.present? ? where("LOWER(name) LIKE ?", "%#{sanitize_sql_like(q.to_s.downcase)}%") : all }

    # A tag or an id. The tag is what a person wrote and what the URL says;
    # the id is what a machine that has one will send.
    def self.friendly(key)
      find_by(tag: key.to_s.strip.downcase) || find_by(id: key)
    end

    # The whole tree flat, each project directly under the one above it, so a
    # list still reads as a shape.
    def self.in_tree_order
      roots.flat_map(&:with_descendants)
    end

    # The tag is the address.
    def to_param = tag

    def with_descendants = [ self, *children.flat_map(&:with_descendants) ]

    def ancestors = parent ? [ *parent.ancestors, parent ] : []

    def descendants = children.flat_map(&:with_descendants) - [ self ]

    def depth = ancestors.size

    def root? = parent_id.nil?

    # The whole line, root first. What something has to carry all of to be
    # here rather than further up.
    def required_tags = [ *ancestors.map(&:tag), tag ].compact

    # Every source's answer, in the order the host registered them, with each
    # one's items already placed. A source that was down is here too, carrying
    # why: a project of four tools should show the three that answered.
    def readings
      @readings ||= begin
        claimed = descendants.map(&:required_tags)

        Projects.sources.map do |source|
          reading = source.read(tag)
          reading.with(items: reading.items.select { |item| mine?(item, claimed) })
        end
      end
    end

    # What is filed here, across every tool, in the order the sources were
    # registered.
    def items = readings.flat_map(&:items)

    # What was asked and did not answer, for a page that would otherwise be
    # quietly short.
    def sources_down = readings.select(&:down?)

    private
      def normalize_tag
        self.tag = tag.to_s.strip.downcase.presence
      end

      # Mine if it carries my whole line, and if nothing further down claims
      # it. Two subprojects at the same depth are not a tie to be broken:
      # something carrying both lines belongs to both.
      def mine?(item, claimed)
        item.carries?(required_tags) && claimed.none? { |tags| item.carries?(tags) }
      end

      def parent_is_somewhere_else
        return if parent.nil?

        if parent == self
          errors.add(:parent, "cannot be the project itself")
        elsif persisted? && descendants.include?(parent)
          errors.add(:parent, "cannot be one of its own subprojects")
        end
      end
  end
end
