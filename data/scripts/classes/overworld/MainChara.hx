import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.util.FlxSpriteUtil;

class MainChara {
    public var sprite:FlxSprite;
    public var animFacing:String = null;
    public var allowCollisions:Bool = true;

    public var boxHitboxHeight:Float = 0;

    public var collisionLines:Array<{x1:Float, y1:Float, x2:Float, y2:Float, slope:Bool}> = [];
    public var collisionRects:Array<{x:Float, y:Float, w:Float, h:Float, callback:()->Void}> = [];

    public var rect_rect_collision:Dynamic->Void = null;
    public var ellipse_line_collision:Dynamic->Void = null;

    public var previous:{x:Float, y:Float} = {x: 0, y: 0};
    public var delta:{x:Float, y:Float} = {x: 0, y: 0};

    public var turned:Int = 1;
    public var moving:Bool = false;
    public var facing:Int = null;

    public function new(x:Float, y:Float, spritePath:String = null, _facing:String) {
        sprite = new FlxSprite(x, y, spritePath);

        // Align to 3x grid
        if ((x % 3) == 2) x += 1;
        if ((x % 3) == 1) x -= 1;
        if ((y % 3) == 2) y += 1;
        if ((y % 3) == 1) y -= 1;
        sprite.setPosition(x, y);

        // Load sprite atlas & animations
        sprite.frames = Paths.getAsepriteAtlasAlt("images/overworld/characters/dustinbf");
        sprite.animation.addByPrefix("l", "Left", 6, true);
        sprite.animation.addByPrefix("r", "Right", 6, true);
        sprite.animation.addByPrefix("d", "Down", 6, true);
        sprite.animation.addByPrefix("u", "Up", 6, true);

        sprite.animation.play(animFacing = _facing, true);
        sprite.animation.stop();

        boxHitboxHeight = (sprite.height - 18) * 0.7;
    }

    public function update(elapsed:Float) {
        var x = sprite.x;
        var y = sprite.y;

        previous.x = x; previous.y = y;
        if (moving) {
            animFacing = switch (facing) {
                case 0: "d";
                case 1: "r";
                case 2: "u";
                default: "l";
            };
            sprite.animation.play(animFacing, sprite.animation.name != animFacing);
        }

        turned = 1; moving = false;
        if (FlxG.keys.pressed.LEFT) {
            sprite.x -= (previous.x == (x + 3)) ? 2 : 3;
            moving = true;
            if (FlxG.keys.pressed.UP && facing == 2) turned = 0;
            if (FlxG.keys.pressed.DOWN && facing == 0) turned = 0;
            if (turned == 1) facing = 3;
        }
        if (FlxG.keys.pressed.UP) {
            sprite.y -= 3;
            moving = true;
            if (FlxG.keys.pressed.RIGHT && facing == 1) turned = 0;
            if (FlxG.keys.pressed.LEFT && facing == 3) turned = 0;
            if (turned == 1) facing = 2;
        }
        if (FlxG.keys.pressed.RIGHT && !FlxG.keys.pressed.LEFT) {
            sprite.x += (previous.x == (x - 3)) ? 2 : 3;
            moving = true;
            if (FlxG.keys.pressed.UP && facing == 2) turned = 0;
            if (FlxG.keys.pressed.DOWN && facing == 0) turned = 0;
            if (turned == 1) facing = 1;
        }
        if (FlxG.keys.pressed.DOWN && !FlxG.keys.pressed.UP) {
            sprite.y += 3;
            moving = true;
            if (FlxG.keys.pressed.RIGHT && facing == 1) turned = 0;
            if (FlxG.keys.pressed.LEFT && facing == 3) turned = 0;
            if (turned == 1) facing = 0;
        }

        update_delta();
        if (allowCollisions)
            update_collisions();

        if (!moving) {
            sprite.animation.stop();
            sprite.animation?.curAnim?.curFrame = 1;
        }

        sprite.update(elapsed);

        var camera:FlxCamera = sprite.cameras[0];
        if (camera != null)
            camera.scroll.set(
                sprite.x + (sprite.width / 2) - (FlxG.width / 2),
                sprite.y + (sprite.height / 2) - (FlxG.height / 2)
            );
    }

    public function update_delta() {
        delta.x = sprite.x - previous.x;
        delta.y = sprite.y - previous.y;
    }

    public function update_collisions() {
        for (rect in collisionRects)
            if (rect_collision(rect) && rect.callback != null) rect.callback();
        for (line in collisionLines)
            if (line_collision(line)) seperate_rect_line(line, false);
    }

    public function seperate_rect_line(line:{x1:Float, y1:Float, x2:Float, y2:Float}, ?ignoreslopes:Bool = false) {
        if (!ignoreslopes && line.slope) {
            sprite.x -= delta.x; sprite.y -= delta.y;

            var playerAngle:Float = Math.atan2(delta.y, delta.x);
            var deltaPower:Float = Math.sqrt(delta.x * delta.x + delta.y * delta.y);
            var lineAngle:Float = Math.atan2(line.y2 - line.y1, line.x2 - line.x1);
            var angleDiff:Float = lineAngle - playerAngle;

            if (Math.abs(angleDiff) >= Math.PI / 2) angleDiff += Math.PI;

            sprite.x += Math.cos(playerAngle + angleDiff) * deltaPower;
            sprite.y += Math.sin(playerAngle + angleDiff) * deltaPower;

        } else {
            sprite.x -= delta.x;
            if (line_collision(line, false)) {
                sprite.x += delta.x; sprite.y -= delta.y;
            }
        }
        update_delta();
    }

    public function rect_collision(rect:{x:Float, y:Float, w:Float, h:Float}): Bool {
        return rect_rect_collision(
            rect.x, rect.y,
            rect.w, rect.h,
            sprite.x + (sprite.width / 2) - (sprite.width * .75 / 2),
            (sprite.y + sprite.height) - boxHitboxHeight - 3,
            sprite.width * .75, boxHitboxHeight
        );
    }

    public function line_collision(line:{x1:Float, y1:Float, x2:Float, y2:Float}, ?checkbounds:Bool = true):Bool  {
        if (checkbounds && !rect_rect_collision(
            (line.x1 - (line.x2 < line.x1 ? Math.abs(line.x1 - line.x2) : 0)),
            (line.y1 - (line.y2 < line.y1 ? Math.abs(line.y1 - line.y2) : 0)),
            Math.abs(line.x1 - line.x2),
            Math.abs(line.y1 - line.y2),
            sprite.x + (sprite.width / 2) - (sprite.width * .75 / 2),
            (sprite.y + sprite.height) - boxHitboxHeight - 3,
            sprite.width * .75, boxHitboxHeight
        )) return null; // boundingbox first

        return ellipse_line_collision(
            sprite.x + sprite.width / 2,
            (sprite.y + sprite.height) - (boxHitboxHeight / 2) - 3,
            (sprite.width * .75) / 2, boxHitboxHeight / 2,
            line.x1, line.y1,
            line.x2, line.y2
        );
    }
}
