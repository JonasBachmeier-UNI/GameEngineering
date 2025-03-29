using Godot;
using System;
using System.Collections.Generic;

public partial class InBetweenScene : Control 
{
	[Export(PropertyHint.Range, "2,6")]
	
	public int ButtonCount = 6;

	private GridContainer _gridContainer;
	private ButtonGroup _btnGroup;
	private Button _templateButton;
	private List<Button> _buttons = new List<Button>();

	[Export] public Texture2D[] ButtonIcons;
	
	 public override void _Ready()
	{
		_gridContainer = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer");
		_templateButton = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer").GetNodeOrNull<Button>("CharacterSelector");
		_btnGroup = new ButtonGroup();

		_templateButton.Visible = false; // Hide the template button

		UpdateButtons();
		
		for (int i = 0; i < GlobalCharacterManager.Instance.Characters.Count ; i++) {
			GD.Print("Char " + i + " with " + GlobalCharacterManager.Instance.GetCharacter(i).HeadSprite);
		}
	}

	private void UpdateButtons()
	{
		int currentCount = _buttons.Count;

		for (int i = 0; i < ButtonCount; i++)
		{
			Button btn;
			if (i < currentCount)
			{
				// Reuse existing button
				btn = _buttons[i];
			}
			else
			{
				// Clone the template button
				btn = (Button)_templateButton.Duplicate();
				btn.ButtonGroup = _btnGroup;
				_gridContainer.AddChild(btn);
				_buttons.Add(btn);

				int value = i + 1;
				btn.Pressed += () => OnButtonPressed(value);
			}

			
			CharacterDisplay display = btn.GetNode<CharacterDisplay>("CharacterDisplay");
			
			display.LoadCharacter(i);
			
			GD.Print("Button " + btn.GetNode<CharacterDisplay>("CharacterDisplay").CharacterIndex);

			// Update button text
			Character character = GlobalCharacterManager.Instance.GetCharacter(i);
			btn.Text = character.Name;

			btn.Visible = true; // Ensure the button is visible
		}

		// Remove excess buttons
		for (int i = ButtonCount; i < currentCount; i++)
		{
			Button btn = _buttons[i];
			_gridContainer.RemoveChild(btn);
			btn.QueueFree();
		}

		// Keep only the necessary amount of buttons
		_buttons.RemoveRange(ButtonCount, _buttons.Count - ButtonCount);
	}

	private void OnButtonPressed(int value)
	{
		GD.Print("Selected Value: " + value);
		GD.Print("Character: " + GlobalCharacterManager.Instance.GetCharacter(0).HeadSprite);
		GD.Print("Character: " + GlobalCharacterManager.Instance.GetCharacter(1).HeadSprite);
	}
}
