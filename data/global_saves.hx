//

static function load_save() {
    // if (FlxG.save.data.dustinBoughtStuff == null) FlxG.save.data.dustinBoughtStuff = ["The CD"];
    FlxG.save.data.mechanics ??= true;

    FlxG.save.data.nh ??= false;
    Options.devMode ??= false;

    FlxG.save.data.dustinBoughtStuff ??= [];
    FlxG.save.data.dustinSeenUnlockAnims ??= [];
    FlxG.save.data.dustinCash ??= 0;
    FlxG.save.data.dustinBeatEverything ??= false;

    load_shaders_data();

    // CAUSES ISSUES WITH MEMORY
    Options.streamedMusic = false;
    Options.streamedVocals = false;

    // Chezz killed me 
    Options.colorHealthBar = true;
}

static function load_shaders_data() {
    FlxG.save.data.bloom ??= true;
    FlxG.save.data.particles ??= true;
    FlxG.save.data.godrays ??= true;
    FlxG.save.data.glitch ??= true;

    FlxG.save.data.fog ??= true;
    FlxG.save.data.water ??= true;
    FlxG.save.data.chromwarp ??= true;
    FlxG.save.data.warp ??= true;
    FlxG.save.data.fire ??= true;

    FlxG.save.data.static ??= true;
    FlxG.save.data.pixel ??= true;
    FlxG.save.data.saturation ??= true;
    FlxG.save.data.impact ??= true;
}

static function set_shaders_high() {
    Options.gameplayShaders = true;

    FlxG.save.data.bloom = true;
    FlxG.save.data.particles = true;
    FlxG.save.data.godrays = true;
    FlxG.save.data.glitch = true;

    FlxG.save.data.fog = true;
    FlxG.save.data.water = true;
    FlxG.save.data.chromwarp = true;
    FlxG.save.data.warp = true;
    FlxG.save.data.fire = true;

    FlxG.save.data.static = true;
    FlxG.save.data.pixel = true;
    FlxG.save.data.saturation = true;
    FlxG.save.data.impact = true;
}

static function set_shaders_low() {
    Options.gameplayShaders = false;

    FlxG.save.data.bloom = false;
    FlxG.save.data.particles = false;
    FlxG.save.data.godrays = false;
    FlxG.save.data.glitch = false;

    FlxG.save.data.fog = false;
    FlxG.save.data.water = false;
    FlxG.save.data.chromwarp = false;
    FlxG.save.data.warp = false;
    FlxG.save.data.fire = false;

    FlxG.save.data.static = false;
    FlxG.save.data.pixel = false;
    FlxG.save.data.saturation = false;
    FlxG.save.data.impact = false;
}

static var FULL_VOLUME:Bool = false;

static var weekPlaylist:Array<Dynamic> = [];
static var weekDifficulty:String = "";