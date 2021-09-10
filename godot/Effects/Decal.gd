extends Spatial

tool

export(Texture) var texture

func _process(delta):
	$Decal.get_active_material(0).set_shader_param("texture_albedo", texture)
