using Godot;
using System.Collections.Generic;

public partial class GlobalCharacterManager : Node
{
	public static GlobalCharacterManager Instance; // Singleton instance

	public List<Character> Characters = new List<Character>(); // Store six characters

	public override void _Ready()
	{
		if (Instance == null)
		{
			Instance = this;
			SetProcess(false); // Disable processing to save resources
			InitializeCharacters();
		}
		else
		{
			QueueFree(); // Ensure only one instance exists
		}
	}
	
	public bool HasCharacter(int index) {
		return true;
	}

	private void InitializeCharacters()
	{
		// Create six empty characters
		for (int i = 0; i < 6; i++)
		{
			Characters.Add(new Character($"Character {i + 1}"));
		}
	}

	public void SaveCharacter(int index, Character character)
	{
		if (index >= 0 && index < Characters.Count)
		{
			Characters[index] = character;
			GD.Print("Saved " + index);
		}
	}

	public Character GetCharacter(int index)
	{
		return (index >= 0 && index < Characters.Count) ? Characters[index] : null;
	}
}
