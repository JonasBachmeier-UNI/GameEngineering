using Godot;
using System.Collections.Generic;
using System;

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
	
	public int GetCharacterAmount() {
		return Characters.Count;
	}
	
	public Godot.Collections.Array GetCharacters()
	{
		var array = new Godot.Collections.Array();

		foreach (var character in Characters)
		{
			var dict = new Godot.Collections.Dictionary
			{
				{ "id", chracter.Id},
				{ "name", character.Name },
				{ "health", character.Health },
				{ "damage", character.Damage },
				{ "defense", character.Defense }
				
			};
			array.Add(dict);
		}

		return array;
	}
	
	public void UpdateCharacterHealth(int index, int health) {
		var character = Characters.FirstOrDefault(c => c.Id == index); 
		character.Health = health;
	}
	
	public void KillCharacter(int index) {
		var character = Characters.FirstOrDefault(c => c.Id == index); 
		Characters.Remove(character);
	}
	
	public bool HasCharacter(int index) {
		return true;
	}

	private void InitializeCharacters()
	{
		List<string> possibleNames = new List<string> { "Bert", "Luca", "Tim", "Sabine", "Chrissi", "Steven" };
		List<string> possibleHeadSprites = new List<string> { "res://Sprites/Head1.png", "res://Sprites/Head2.png", "res://Sprites/Head3.png", "res://Sprites/Head4.png", "res://Sprites/Head5.png", "res://Sprites/Head6.png" };
		List<string> possibleBodySprites = new List<string> { "res://Sprites/Body1.png", "res://Sprites/Body2.png", "res://Sprites/Body3.png", "res://Sprites/Body4.png", "res://Sprites/Body5.png", "res://Sprites/Body6.png" };
		List<string> possibleTopSprites = new List<string> { "res://Sprites/Top1.png", "res://Sprites/Top2.png", "res://Sprites/Top3.png", "res://Sprites/Top4.png", "res://Sprites/Top5.png", "res://Sprites/Top6.png" };

		Random rng = new Random();
		Shuffle(possibleNames, rng);
		Shuffle(possibleHeadSprites, rng);
		Shuffle(possibleBodySprites, rng);
		Shuffle(possibleTopSprites, rng);

		// Create six characters
		for (int i = 0; i < 6; i++)
		{
			Character character;

			if (i < 3)
			{
				character = new Character($"Character {i + 1}");
				character.Id = i;
			}
			else
			{
				character = new Character(possibleNames[i]);
				character.SetSprite("Head", possibleHeadSprites[i]);
				character.SetSprite("Body", possibleBodySprites[i]);
				character.SetSprite("Top", possibleTopSprites[i]);
				character.HeadGradientColor = GetRandomColor();
				character.BodyGradientColor = GetRandomColor();
				character.TopGradientColor = GetRandomColor();
				character.Id = i;
			}

			Characters.Add(character);
		}
	}

	private void Shuffle<T>(List<T> list, Random rng)
	{
		int n = list.Count;
		while (n > 1)
		{
			n--;
			int k = rng.Next(n + 1);
			T value = list[k];
			list[k] = list[n];
			list[n] = value;
		}
	}

	private Color GetRandomColor()
	{
		Random rng = new Random();
		return new Color((float)rng.NextDouble(), (float)rng.NextDouble(), (float)rng.NextDouble());
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
