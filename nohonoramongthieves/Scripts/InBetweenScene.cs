using Godot;
using System;
using System.Collections.Generic;

public enum Scenario
{
	Malus, // Scenario 1
	Bonus, // Scenario 2
	SRetten, // Scenario 3
	MalusBonus, // Scenario 4
	CRetten // Scenario 5
}

public partial class InBetweenScene : Control 
{
	[Export(PropertyHint.Range, "2,6")]
	
	public int ButtonCount = 6;

	private GridContainer _gridContainer;
	private ButtonGroup _btnGroup;
	private Button _templateButton;
	private Button _nextButton;
	private List<Button> _buttons = new List<Button>();
	public int selectedCharacterIndex = 0;

	[Export] public Texture2D[] ButtonIcons;
	
	 public override void _Ready()
	{
		_gridContainer = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer");
		_templateButton = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer").GetNodeOrNull<Button>("CharacterSelector");
		_nextButton = GetNode<Button>("NextButton");
		_nextButton.Pressed += () => OnNextButtonPressed();
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
		selectedCharacterIndex = value;
	}
	
	private void OnNextButtonPressed()
	{
		Scenario selectedScenario = Scenario.Malus;

		switch (selectedScenario)
		{
			case Scenario.Malus:
				HandleMalusScenario();
				break;

			case Scenario.Bonus:
				HandleBonusScenario();
				break;

			case Scenario.SRetten:
				HandleSRettenScenario();
				break;

			case Scenario.MalusBonus:
				HandleMalusBonusScenario();
				break;

			case Scenario.CRetten:
				HandleCRettenScenario();
				break;
		}
		
		SceneManager.Instance.NextScene();
	}

	// Handle the logic for each scenario
	private void HandleMalusScenario()
	{
		// Scenario 1: The character who disables the trap loses 15 HP
		int selectedCharacterIndex = GetSelectedCharacterIndex();
		Character selectedCharacter = GlobalCharacterManager.Instance.GetCharacter(selectedCharacterIndex);
		selectedCharacter.Health -= 15;
		GD.Print(selectedCharacter.Name + " lost 15 HP due to a trap!");
	}

	private void HandleBonusScenario()
	{
		// Scenario 2: A character gains a bonus (double damage)
		int selectedCharacterIndex = GetSelectedCharacterIndex();
		Character selectedCharacter = GlobalCharacterManager.Instance.GetCharacter(selectedCharacterIndex);
		selectedCharacter.Damage *= 2;  // Double damage
		GD.Print(selectedCharacter.Name + " now deals double damage!");
	}

	private void HandleSRettenScenario()
	{
		// Scenario 3: Character [C] is saved by [S], where [S] sacrifices themselves
		int characterToSaveIndex = GetSelectedCharacterIndex();
		Character characterToSave = GlobalCharacterManager.Instance.GetCharacter(characterToSaveIndex);
		int sacrificingCharacterIndex = GetOtherCharacterIndex(characterToSaveIndex);
		Character sacrificingCharacter = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex);

		sacrificingCharacter.Health = 0;  // Sacrificing character dies
		characterToSave.Health += 0;  // No change for character to save, just saved
		GD.Print(sacrificingCharacter.Name + " sacrificed themselves to save " + characterToSave.Name + "!");
	}

	private void HandleMalusBonusScenario()
	{
		// Scenario 4: One character loses 10 HP and another gains 15 HP
		int characterToLoseHPIndex = GetSelectedCharacterIndex();
		Character characterToLoseHP = GlobalCharacterManager.Instance.GetCharacter(characterToLoseHPIndex);
		characterToLoseHP.Health -= 10;

		/*
		int characterToGainHPIndex = GetOtherCharacterIndex(characterToLoseHPIndex);
		Character characterToGainHP = GlobalCharacterManager.Instance.GetCharacter(characterToGainHPIndex);
		characterToGainHP.Health += 15;

		GD.Print(characterToLoseHP.Name + " lost 10 HP and " + characterToGainHP.Name + " gained 15 HP from the artifact!"); */
	}

	private void HandleCRettenScenario()
	{
		// Scenario 5: Character [C] is saved by [S] sacrificing themselves
		int characterToSaveIndex = GetSelectedCharacterIndex();
		Character characterToSave = GlobalCharacterManager.Instance.GetCharacter(characterToSaveIndex);
		int sacrificingCharacterIndex = GetOtherCharacterIndex(characterToSaveIndex);
		Character sacrificingCharacter = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex);

		sacrificingCharacter.Health = 0;  // Sacrificing character dies
		characterToSave.Health += 0;  // No change for character to save, just saved
		GD.Print(sacrificingCharacter.Name + " sacrificed themselves to save " + characterToSave.Name + "!");
	}
	
	private int GetSelectedCharacterIndex()
	{
		return selectedCharacterIndex; 
		//GlobalCharacterManager.Instance.GetCharacter(selectedCharacterIndex);
	}
	
	private int GetOtherCharacterIndex(int excludeIndex)
	{
		return (excludeIndex + 1) % GlobalCharacterManager.Instance.Characters.Count;
	}
}
