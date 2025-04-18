using Godot;
using System;
using System.Runtime.CompilerServices;

public partial class StartMenu : Control
{
    private PackedScene _optionsMenuScene;
    private PackedScene _test;

    private Button _startButton;
    private Button _optionsButton;
    private Button _quitButton;

    public override void _Ready()
    {
        _optionsMenuScene = GD.Load<PackedScene>("res://scenes/options_menu.tscn");
        _test = GD.Load<PackedScene>("res://scenes/action_select.tscn");

        _startButton = GetNode<Button>("StartButton");
        _optionsButton = GetNode<Button>("OptionsButton");
        _quitButton = GetNode<Button>("QuitButton");

        _startButton.Pressed += _OnStartButtonPressed;
        _optionsButton.Pressed += _OnOptionsButtonPressed;
        _quitButton.Pressed += _OnQuitButtonPressed;
    }

    private void _OnStartButtonPressed()
    {
        Node current_scene = GetTree().CurrentScene;

        Control optionsMenuInstance = _test.Instantiate<Control>();

        current_scene.AddChild(optionsMenuInstance);
    }

    private void _OnOptionsButtonPressed()
    {
        GD.Print("Options button pressed");
        Node current_scene = GetTree().CurrentScene;
        
        Control optionsMenuInstance = _optionsMenuScene.Instantiate<Control>();

        current_scene.AddChild(optionsMenuInstance);
    }

    private void _OnQuitButtonPressed()
	{
		GetTree().Quit();
	}
}
