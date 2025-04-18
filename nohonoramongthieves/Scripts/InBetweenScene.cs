using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public enum Scenario
{
	Malus, // Scenario 1
	Bonus, // Scenario 2
	SRetten, // Scenario 3
	CRetten, // Scenario 4
	Gewonnen
}

public partial class InBetweenScene : Control 
{
	[Export(PropertyHint.Range, "2,6")]
	
	public int ButtonCount = 6;
	
	public Scenario selectedScenario = Scenario.Malus;
	
	
	public List<string> scenarioNames =  new List<string> { "Malus", "Bonus", "SRetten", "CRetten", "Gewonnen"};

	private GridContainer _gridContainer;
	private ButtonGroup _btnGroup;
	private Button _templateButton;
	private Button _nextButton;
	private RichTextLabel _scenarioDescriptionLabel;
	private TextureRect _scenarioImage;
	private List<Button> _buttons = new List<Button>();
	public int selectedCharacterIndex = 0;
	private int sacrificingCharacterIndex = -1;
	private int rescuingCharacterIndex = -1;

	
	 public override void _Ready()
	{
		_gridContainer = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer");
		_templateButton = GetNode<HBoxContainer>("HBoxContainer").GetNode<GridContainer>("GridContainer").GetNodeOrNull<Button>("CharacterSelector");
		_nextButton = GetNode<Button>("NextButton");
		_nextButton.Pressed += () => OnNextButtonPressed();
		_btnGroup = new ButtonGroup();
		_scenarioDescriptionLabel = GetNode<VBoxContainer>("VBoxContainer").GetNode<Panel>("Panel").GetNode<RichTextLabel>("RichTextLabel");
		_scenarioImage = GetNode<TextureRect>("TextureRect");
		selectedScenario = (Scenario)Enum.GetValues(typeof(Scenario)).GetValue(SceneManager.Instance.GetCurrentScenarioId());

		_templateButton.Visible = false;
		
		ButtonCount = GlobalCharacterManager.Instance.Characters.Count;

		InitializeScenario();
		
		UpdateButtons();
		
		for (int i = 0; i < GlobalCharacterManager.Instance.Characters.Count ; i++) {
			GD.Print("Char " + i + " with " + GlobalCharacterManager.Instance.GetCharacter(i).HeadSprite);
		}
	}

	/*
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
	} */
	
	private void UpdateButtons()
	{
		// Clear existing buttons
		foreach (Button btn in _buttons)
		{
			_gridContainer.RemoveChild(btn);
			btn.QueueFree();
		}
		_buttons.Clear();
		
		// Determine which characters to show based on scenario
		List<int> characterIndicesToShow = new List<int>();
		
		if (selectedScenario == Scenario.SRetten || selectedScenario == Scenario.CRetten)
		{
			// For Retten scenarios, we only show the victim to be saved and sacrificial character
			if (sacrificingCharacterIndex >= 0)
				characterIndicesToShow.Add(sacrificingCharacterIndex);
			
			if (rescuingCharacterIndex >= 0)
				characterIndicesToShow.Add(rescuingCharacterIndex);
		}
		else
		{
			// For other scenarios, show all characters up to ButtonCount
			for (int i = 0; i < Math.Min(ButtonCount, GlobalCharacterManager.Instance.Characters.Count); i++)
			{
				characterIndicesToShow.Add(i);
			}
		}
		
		// Create buttons for the characters we want to show
		foreach (int charIndex in characterIndicesToShow)
		{
			// Clone the template button
			Button btn = (Button)_templateButton.Duplicate();
			btn.ButtonGroup = _btnGroup;
			_gridContainer.AddChild(btn);
			_buttons.Add(btn);
			
			int value = charIndex;
			btn.Pressed += () => OnButtonPressed(value);

			// Load character display
			CharacterDisplay display = btn.GetNode<CharacterDisplay>("CharacterDisplay");
			display.LoadCharacter(charIndex);
			
			// Update button text
			Character character = GlobalCharacterManager.Instance.GetCharacter(charIndex);
			
			// Add special role label if needed
			if (charIndex == sacrificingCharacterIndex)
			{
				btn.Text = character.Name + " (Opfer)";
				btn.Modulate = new Color(1, 0.7f, 0.7f); // Reddish tint
			}
			else if (charIndex == rescuingCharacterIndex)
			{
				btn.Text = character.Name + " (Retter)";
				btn.Modulate = new Color(0.7f, 1, 0.7f); // Greenish tint
			}
			else
			{
				btn.Text = character.Name;
			}
			
			btn.Visible = true;
		}
	}
	
	private void InitializeScenario()
	{
		Random random = new Random();

		// Select random characters for each role based on scenario
		if (selectedScenario == Scenario.SRetten || selectedScenario == Scenario.CRetten)
		{
			var allCharacters = GlobalCharacterManager.Instance.Characters;

			List<Character> sacrificingCandidates;
			List<Character> rescuingCandidates;

			if (selectedScenario == Scenario.CRetten)
			{
				sacrificingCandidates = allCharacters.Where(c => c.Id <= 2).ToList();
				rescuingCandidates = allCharacters.Where(c => c.Id > 2).ToList();
			}
			else if (selectedScenario == Scenario.SRetten)
			{
				sacrificingCandidates = allCharacters.Where(c => c.Id > 2).ToList();
				rescuingCandidates = allCharacters.Where(c => c.Id <= 2).ToList();
			}
			else
			{
				sacrificingCandidates = allCharacters;
				rescuingCandidates = allCharacters;
			}

			if (sacrificingCandidates.Count > 0 && rescuingCandidates.Count > 0)
			{
				var sacrificingCharacter = sacrificingCandidates[random.Next(sacrificingCandidates.Count)];
				sacrificingCharacterIndex = allCharacters.IndexOf(sacrificingCharacter);

				Character rescuingCharacter;
				do
				{
					rescuingCharacter = rescuingCandidates[random.Next(rescuingCandidates.Count)];
					rescuingCharacterIndex = allCharacters.IndexOf(rescuingCharacter);
				} while (rescuingCharacter == sacrificingCharacter && rescuingCandidates.Count > 1);
			}
		}
		// Update scenario description
		UpdateScenarioDescription();
	}
	
	private void UpdateScenarioDescription()
	{
		if (_scenarioDescriptionLabel == null)
			return;
			
		string description = "";
		
		var logger = (GodotObject)GetNode("/root/Logger");
		logger.Call("on_scenario_started", scenarioNames[(int)selectedScenario]);
		
		switch (selectedScenario)
		{
			case Scenario.Malus:
				description = "Ihr betretet einen schmalen Gang auf dem Weg tiefer in die Schatzkammer, dessen Wände von kunstvoll gearbeiteten Platten bedeckt ist. Abgelenkt von der Verzierung merkt ihr nicht wie einer von euch auf eine Druckplatte tritt. Plötzlich aktiviert sich ein mechanisches System – scharfe Klingen drohen, eine tödliche Falle für unsere Helden zu werden. Nur ein schneller Eingriff kann diese Gefahr bannen, doch die klingen springen bereits aus der Wand. Der Character der die Falle entschärft verliert 15 HP.";
				_scenarioImage.Texture = GD.Load<Texture2D>("res://assets/DecisionImages/Gemini_Blades.jpg");
				break;
				
			case Scenario.Bonus:
				description = "In einem verborgenen Nischenraum der Schatzkammer entdeckt ihr einen schimmernden Trank, der in einem alten, mit mystischen Symbolen verzierten Gefäß ruht. Ein Stück pergament neben dem Trank spezifiziert, wie der Trank genutz wurde um heldenhafte Stärke hervorzubringen. Der Trank verleiht einem Character Stärke und lässt ihn mit doppelt so viel Schaden angeifen.";
				_scenarioImage.Texture = GD.Load<Texture2D>("res://assets/DecisionImages/Gemini_Trank.jpg");
				break;
				
			case Scenario.SRetten:
				_scenarioImage.Texture = GD.Load<Texture2D>("res://assets/DecisionImages/Gemini_FallenFloor.jpg");
				if (sacrificingCharacterIndex >= 0 && rescuingCharacterIndex >= 0)
				{
					string sacrificeName = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex).Name;
					string rescueName = GlobalCharacterManager.Instance.GetCharacter(rescuingCharacterIndex).Name;
					description = $"Ihr betretet einen Raum, in dem der Boden aus loser, bröckelnder Steinfliese besteht. Ein lauter Knall und das Krachen von zerbrechendem Stein hallen durch den Raum. {sacrificeName} gerät ins Straucheln, der Boden gibt nach und droht, ihn in die Tiefe zu stürzen. Vor euch steht eine herzzereißende Wahl: {rescueName} steht neben dem Geschehnis und könnte {sacrificeName} retten indem er ihn in letzter Sekunde an sich zieht, doch durch das Momentum würde {rescueName} vermutlich selbst in die Tiefe stürzen. Wen möchtest du retten?";
				}
				else
				{
					description = "A character will sacrifice themselves to save another.";
				}
				break;
				
			case Scenario.CRetten:
				_scenarioImage.Texture = GD.Load<Texture2D>("res://assets/DecisionImages/Gemini_Szepter.jpg");
				if (sacrificingCharacterIndex >= 0 && rescuingCharacterIndex >= 0)
				{
					string sacrificeName = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex).Name;
					string rescueName = GlobalCharacterManager.Instance.GetCharacter(rescuingCharacterIndex).Name;
					description = $"Ihr betretet einen geheimnisvollen Raum, in dessen Zentrum ein uralter Altar thront, umgeben von schimmernden Runen und einem unheimlich pulsierenden Licht. Plötzlich wird {sacrificeName} von einem Art Zepter attakiert. Es dicht gebündelter Strahl kommt aus dem Zepter und scheint die Lebensenergie von {sacrificeName} auszusaugen. {rescueName} steht in der nähe des Zepters und könnte sich zwischen das Zepter und {sacrificeName} in den Strahl werfen, um ihn/sie zu retten. Das würde {rescueName} töten aber {sacrificeName} retten. Wen rettest du?";
				}
				else
				{
					description = "A character will sacrifice themselves to save the one you select.";
				}
				break;
			case Scenario.Gewonnen:
				description = "Nach einer gefährlichen Reise durch tückische Fallen und herausfordernde Prüfungen haben die Helden erfolgreich den großen Schatz am Ende der Kammer geborgen. Mit strahlenden Augen und Herzen voller Freude feiern sie ihren triumphalen Fund, während Goldartefakte und Juwelen in einem unermesslichen Haufen vor ihnen glänzen.";
				_scenarioImage.Texture = GD.Load<Texture2D>("res://Assets/DecisionImages/Gemini_Win.jpg");
				break;
		}
		
		_scenarioDescriptionLabel.Text = description;
	}

	private void OnButtonPressed(int value)
	{
		selectedCharacterIndex = value;
		var logger = (GodotObject)GetNode("/root/Logger");
		Character savingCharacter = GlobalCharacterManager.Instance.GetCharacter(selectedCharacterIndex);
		Character sacrificingCharacter = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex);
		if (selectedScenario == Scenario.SRetten || selectedScenario == Scenario.CRetten) {
			logger.Call("on_scenario_character_selected", scenarioNames[(int)selectedScenario], savingCharacter.Id, sacrificingCharacter.Id);
		} else {
			logger.Call("on_scenario_character_selected", scenarioNames[(int)selectedScenario], savingCharacter.Id, "");
		}
	}
	
	private void OnNextButtonPressed()
	{

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

			case Scenario.CRetten:
				HandleCRettenScenario();
				break;
		}
		
		var logger = (GodotObject)GetNode("/root/Logger");
		logger.Call("on_scenario_ended", scenarioNames[(int)selectedScenario]);
		
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
		Character savingCharacter = GlobalCharacterManager.Instance.GetCharacter(rescuingCharacterIndex);
		Character sacrificingCharacter = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex);

		if (rescuingCharacterIndex == GetSelectedCharacterIndex()) {
			GlobalCharacterManager.Instance.KillCharacter(sacrificingCharacter.Id);
		} else {
			GlobalCharacterManager.Instance.KillCharacter(savingCharacter.Id);
		}
	}

	private void HandleCRettenScenario()
	{
		// Scenario 4: Character [C] is saved by [S] sacrificing themselves
		Character savingCharacter = GlobalCharacterManager.Instance.GetCharacter(rescuingCharacterIndex);
		Character sacrificingCharacter = GlobalCharacterManager.Instance.GetCharacter(sacrificingCharacterIndex);

		if (rescuingCharacterIndex == GetSelectedCharacterIndex()) {
			GlobalCharacterManager.Instance.KillCharacter(sacrificingCharacter.Id);
		} else {
			GlobalCharacterManager.Instance.KillCharacter(savingCharacter.Id);
		}
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
