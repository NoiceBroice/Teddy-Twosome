package;

import flixel.tweens.misc.ColorTween;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("GAMEPLAY", [
			new DFJKOption(controls),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			#if desktop
			new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new InstantRespawn("Toggle if you instantly respawn after dying."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
		]),
		new OptionCategory("Appearance", [
			new EditorRes("Not showing the editor grid will greatly increase editor performance"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
		]),
		
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input on the score screen."),
			new Optimization("No characters or backgrounds. Just a usual rhythm game layout."),
			new GraphicLoading("On startup, cache every character. Significantly decrease load times. (HIGH MEMORY)"),
			new BotPlay("Showcase your charts and mods with autoplay.")
		]),
		
		new OptionCategory("Saves and Data", [
			#if desktop
			new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		])
		
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<OptionText>;
	public static var versionShit:FlxText;

	public var currentOptions:Array<FlxText> = [];
	var offsetPog:FlxText;
	var targetY:Array<Float> = [];

	var currentSelectedCat:OptionCategory;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('blackbackmenu'));
		bg.color = FlxColor.fromRGB(255, 120, 193);
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);	

		var shade:FlxSprite = new FlxSprite(-205,-100).loadGraphic(Paths.image('Shadescreen', 'shared'));
		shade.setGraphicSize(Std.int(shade.width * 0.65));
		add(shade);

		for (i in 0...options.length)
		{
			var option:OptionCategory = options[i];

			var text:FlxText = new FlxText(125,(42 * i) + 175, 0, option.getName(),20);
			text.color = FlxColor.fromRGB(255,255,255);
			text.setFormat("Hooman Stitch.ttf", 30, FlxColor.WHITE);
			add(text);
			currentOptions.push(text);

			targetY[i] = i;

			trace('option king ' );
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		currentOptions[0].color = FlxColor.RED;

		offsetPog = new FlxText(125,600,0,"Offset: " + FlxG.save.data.offset);
		offsetPog.setFormat("Hooman Stitch.ttf",30,FlxColor.WHITE);
		add(offsetPog);

		super.create();
	}

	var isCat:Bool = false;

	function resyncVocals():Void
	{
		MusicMenu.Vocals.pause();

		FlxG.sound.music.play();
		MusicMenu.Vocals.time = FlxG.sound.music.time;
		MusicMenu.Vocals.play();
	}
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (MusicMenu.Vocals != null)
		{
			if (controls.BACK && !isCat)
			{
				FlxG.switchState(new MainMenuState());
			}
			else if (controls.BACK)
			{
				if (FlxG.sound.music.time > MusicMenu.Vocals.time + 20 || FlxG.sound.music.time < MusicMenu.Vocals.time - 20)
					resyncVocals();
			}
		}


		if (controls.BACK && !isCat)
			FlxG.switchState(new MainMenuState());
		else if (controls.BACK)
		{
			isCat = false;
			for (i in currentOptions)
				remove(i);
			currentOptions = [];
			for (i in 0...options.length)
				{
					// redo shit
					var option:OptionCategory = options[i];
				
					var text:FlxText = new FlxText(125,(42 * i) + 175, 0, option.getName(),20);
					text.color = FlxColor.fromRGB(255,255,255);
					text.setFormat("Hooman Stitch.ttf", 30, FlxColor.WHITE);
					add(text);
					currentOptions.push(text);
				}
				curSelected = 0;
				currentOptions[curSelected].color = FlxColor.RED;
		}
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
		//		FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
		//		FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}
		}
		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		//	FlxG.sound.play(Paths.sound('scrollMenu'));
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
		//	FlxG.sound.play(Paths.sound('scrollMenu'));
		
		if (isCat)
		{
			
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
			{
				if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
							{
								currentSelectedCat.getOptions()[curSelected].right();
								currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
							}
							if (FlxG.keys.pressed.LEFT)
								{
									currentSelectedCat.getOptions()[curSelected].left();
									currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
								}
					}
				else
				{
					if (FlxG.keys.justPressed.RIGHT)
						{
							currentSelectedCat.getOptions()[curSelected].right();
							currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
						}
						if (FlxG.keys.justPressed.LEFT)
							{
								currentSelectedCat.getOptions()[curSelected].left();
								currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
							}
				}
			}
			else
			{

				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset++;
					if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset--;
				}
				else
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset++;
					if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset--;
				}
			}
		}	
		else
		{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset++;
					if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset--;
				}
				else
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset++;
					if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset--;
				}
		}

		offsetPog.text = "Offset: " + FlxG.save.data.offset + " (Left/Right)";		

		if (controls.RESET)
			FlxG.save.data.offset = 0;

		if (controls.ACCEPT)
			{
				//FlxG.sound.play(Paths.sound("confirm",'clown'));
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						// select thingy and redo itself
						for (i in currentOptions)
							remove(i);
						currentOptions = [];
						for (i in 0...currentSelectedCat.getOptions().length)
							{
								// clear and redo everything else
								var option:Option = currentSelectedCat.getOptions()[i];
	
								trace(option.getDisplay());
	
								var text:FlxText = new FlxText(125,(42 * i) + 175, 0, option.getDisplay(),20);
								text.color = FlxColor.fromRGB(255,255,255);
								text.setFormat("Hooman Stitch.ttf", 30, FlxColor.WHITE);
								add(text);
								currentOptions.push(text);
							}
							trace('done');
						currentOptions[curSelected].color = FlxColor.RED;
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					for (i in currentOptions)
						remove(i);
					currentOptions = [];
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							// clear and redo everything else
							var option:Option = currentSelectedCat.getOptions()[i];

							trace(option.getDisplay());

							var text:FlxText = new FlxText(125,(42 * i) + 175, 0, option.getDisplay(),20);
							text.color = FlxColor.fromRGB(255,0,0);
							text.setFormat("Hooman Stitch.ttf", 30, FlxColor.WHITE);
							add(text);
							currentOptions.push(text);
						}
					curSelected = 0;
					currentOptions[curSelected].color = FlxColor.RED;
				}
				
				changeSelection();
			}
		FlxG.save.flush();
	}
	
	
	var isSettingControl:Bool = false;
	
	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
			
		//FlxG.sound.play(Paths.sound("Hover",'clown'));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	
		currentOptions[curSelected].color = FlxColor.fromRGB(255,255,255);
	
		curSelected += change;
	
		if (curSelected < 0)
			curSelected = currentOptions.length - 1;
		if (curSelected >= currentOptions.length)
			curSelected = 0;
	
	
		currentOptions[curSelected].color = FlxColor.RED;
	
		var bullShit:Int = 0;
		
	}
}