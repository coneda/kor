json.set! '@context', 'http://iiif.io/api/presentation/2/context.json'
json.set! '@id', iiif_manifest_url(@entity, format: :json)
json.set! '@type', 'sc:Manifest'

json.label 'blub'
json.description 'bla'
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

# {
#   "@context" : "http://iiif.io/api/presentation/2/context.json",
#   "@id" : "https://static.wendig.io/iiif/image.jpg/manifest.json",
#   "@type" : "sc:Manifest",

#   "label" : "some label",
#   "description" : "some description",
#   "metadata" : [
#     {
#       "label": "filename",
#       "value": "image.jpg"
#     }
#   ],
#   "sequences" : [
#     {
#       "@id" : "https://static.wendig.io/iiif/image.jpg/seq0.json",
#       "@type" : "sc:Sequence",

#       "label": "image.jpg - sequence 1 0",
#       "canvases": [
#         {
#           "@id" : "https://static.wendig.io/iiif/image.jpg/can0.json",
#           "@type" : "sc:Canvas",

#           "label": "image.jpg - image 0",
#           "width" : 450,
#           "height" : 800,
#           "thumbnail": {
#             "@id" : "https://static.wendig.io/iiif/image.jpg",
#             "width": 150,
#             "height": 267,
#             "format": "image/jpeg"
#           },
#           "images": [
#             {
#               "@id" : "https://static.wendig.io/iiif/image.jpg/note0.json",
#               "@type": "oa:Annotation",

#               "motivation": "sc:painting",
#               "on": "https://static.wendig.io/iiif/image.jpg/can0.json",

#               "resource": {
#                 "@id" : "https://static.wendig.io/iiif/image.jpg",
#                 "@type" : "dctypes:Image",

#                 "format" : "image/jpeg",
#                 "width" : 450,
#                 "height" : 800
#               }
#             }
#           ]
#         }
#       ]
#     }
#   ]
# }
