module Projects
  module ApplicationHelper
    # A project's line, as its ancestors and then itself. What tells you where
    # you are in a tree without drawing the tree.
    def project_trail(project)
      safe_join(project.ancestors.map { |ancestor| link_to(ancestor.name, ancestor) }, " / ")
    end

    # A tag, written the way a tag is written everywhere else in the family.
    def project_tag(tag)
      tag.presence && "##{tag}"
    end

    # Whatever a source gave us to draw this small, or nothing — a name and a
    # link is still the thing a project is for.
    #
    # An image is fetched from the host's own door, so the cookie that opened
    # this page opens it too; a run of swatches is drawn here, because a
    # colour is a value and drawing a strip of them is not a calculation.
    def item_figure(item)
      if item.image.present?
        tag.img(src: item.image, alt: "", loading: "lazy", class: "item__image")
      elsif item.swatches.any?
        tag.span(class: "item__swatches") do
          safe_join(item.swatches.map { |swatch| tag.span(class: "item__swatch", style: "--swatch: #{swatch}") })
        end
      end
    end

    # How many things a project holds, said once. A project with nothing in it
    # is a normal state — the tag simply is not on anything yet — so it says
    # so in words rather than showing a zero.
    def gathered_count(count)
      count.zero? ? "Nothing tagged yet" : pluralize(count, "thing")
    end
  end
end
