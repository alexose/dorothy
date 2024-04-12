.PHONY: all outer_shell distance_sensor soil_moisture_sensor temperature_humidity_sensor standoffs

all: outer_shell distance soil_moisture temperature_humidity standoffs

outer_shell:
	openscad dorothy_sensor.scad -D render_outer_shell=1 -D render_brain=0 -D render_standoffs=0 -o outer_shell.stl --enable=fast-csg

standoffs:
	openscad dorothy_sensor.scad -D render_outer_shell=0 -D render_brain=0 -D render_standoffs=1 -o standoffs.stl --enable=fast-csg

distance:
	openscad dorothy_sensor.scad -D render_outer_shell=0 -D render_brain=1 -D brain_type=\"distance\" -D render_standoffs=0 -o distance_brain.stl --enable=fast-csg

soil_moisture:
	openscad dorothy_sensor.scad -D render_outer_shell=0 -D render_brain=1 -D brain_type=\"soil_moisture\" -D render_standoffs=0 -o soil_moisture_brain.stl --enable=fast-csg

temperature_humidity:
	openscad dorothy_sensor.scad -D render_outer_shell=0 -D render_brain=1 -D brain_type=\"temperature_humidity\" -D render_standoffs=0 -o temperature_humidity_brain.stl --enable=fast-csg
