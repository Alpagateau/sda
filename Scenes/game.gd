extends Control
class_name Game

func b64_to_texture_2d(b64 : String) -> Texture2D:
	var image_bytes: PackedByteArray = Marshalls.base64_to_raw(b64)
	var image : Image = Image.new()
	image.load_png_from_buffer(image_bytes)
	return ImageTexture.create_from_image(image)

# To call when there is a response from the server
func load_b64_image(b64_image : String):
	$TextureRect.texture = b64_to_texture_2d(b64_image)
