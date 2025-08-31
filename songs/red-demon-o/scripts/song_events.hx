//
public var camCharacters:FlxCamera;

function create() {
	camCharacters = new FlxCamera(0, 0);
	
	for (cam in [camGame, camHUD, camHUD2]) FlxG.cameras.remove(cam, false);
	for (cam in [camGame, camCharacters, camHUD, camHUD2]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

	stage.getSprite("final_rocks").camera = camGame;
	stage.getSprite("final_rocks").visible = false;

	stage.getSprite("ASGOREOT").cameras = [camCharacters];

	stage.getSprite("shade_overthrone_tutorial").visible = false;
	stage.getSprite("warning_OVERTHRONE").visible = false;

	var spirits = strumLines.members[3].characters[0];
	if (spirits.curCharacter == "spirits") {  // mettaton's arm on asgore's face due to the shader sob  - Nex
		//spirits.x -= 50;
		spirits.y -= 200;
	}
}

function postCreate() {
	camGame.filters = [];
	camHUD.filters = [];

	doWashColor(camGame, 0xFFdd0411, .22, 7);
	doWashColor(camCharacters, 0xffffffff, .15, 4);
	doWashColor(camHUD, 0xffffffff, .16, 8);
	doWashColor(camHUD2, 0xffffffff, .08, 7);
}

function onCountdown(event) event.sprite?.cameras = [camCharacters];

function update(elapsed:Float) {
	camCharacters.scroll = FlxG.camera.scroll;
    camCharacters.zoom = FlxG.camera.zoom;
    camCharacters.angle = FlxG.camera.angle;

    for (strum in strumLines)
        for (char in strum.characters)
            // if (char.curCharacter != "spirits")
				char.cameras = [camCharacters];
}

function doWashColor(cam:FlxCamera, col:Int, ther:Float, spread:Float) {
	var shaderFill = new CustomShader("impact_frames_col");
	shaderFill.threshold = ther;
	shaderFill.impactCol = [((col >> 16) & 0xff)/255, ((col >> 8) & 0xff)/255, (col & 0xff)/255];

	var bloom_new = new CustomShader("bloom_new");
    bloom_new.size = spread*.7; bloom_new.brightness = .6;
    bloom_new.directions = 6; bloom_new.quality = 5;
    bloom_new.threshold = .35;

	if (Options.gameplayShaders && FlxG.save.data.impact) cam.addShader(shaderFill);
	if (Options.gameplayShaders && FlxG.save.data.bloom) cam.addShader(bloom_new);
}