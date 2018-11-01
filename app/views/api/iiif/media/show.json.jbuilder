json.set! '@context', 'http://iiif.io/api/presentation/2/context.json'
json.set! '@id', iiif_manifest_url(@entity, format: :json)
json.set! '@type', 'sc:Manifest'

json.label "#{I18n.t 'activerecord.models.entity', count: 1} #{@entity.id}"
json.description '-'
json.metadata [0] do
  json.label 'filename'
  json.value @entity.medium.original.original_filename
end

json.sequences [0] do
  json.set! '@id', iiif_sequence_url(@entity, format: :json)
  json.set! '@type', 'sc:Sequence'
  json.label 'the only sequence'

  json.canvases [0] do
    json.set! '@id', iiif_canvas_url(@entity, format: :json)
    json.set! '@type', 'sc:Canvas'
    json.label 'the only image'

    json.width @width
    json.height @height

    json.thumbnail do
      json.set! '@id', root_url + @entity.medium.url(:thumbnail).gsub(/\?.*$/, '')
      json.width @thumb_width
      json.height @thumb_height
      json.format 'image/jpeg'
    end

    json.images [0] do
      json.set! '@id', iiif_image_url(@entity, format: :json)
      json.set! '@type', 'oa:Annotation'

      json.motivation 'sc:painting'
      json.on iiif_canvas_url(@entity, format: :json)

      json.resource do
        json.set! '@id', root_url + @entity.medium.url(:normal).gsub(/\?.*$/, '')
        json.set! '@type', 'dctypes:Image'
        json.format 'image/jpeg'
        json.width @width
        json.height @height
      end
    end
  end
end