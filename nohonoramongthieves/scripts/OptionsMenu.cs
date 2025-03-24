using Godot;
using System;

public partial class OptionsMenu : Control
{
    private Button _closeButton;

    public override void _Ready()
	{
        _closeButton = FindChild("CancelButton", true, false) as Button;
        _closeButton.Pressed += _OnCloseButtonPressed;
    }

    private void _OnCloseButtonPressed()
    { 
        QueueFree();
    }
}
