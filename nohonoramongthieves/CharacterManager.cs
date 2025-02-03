using Godot;
using System.Collections.Generic;

public partial class CharacterManager : Control
{
	private List<Character> characters = new List<Character>();

	public override void _Ready()
	{
		for (int i = 1; i <= 3; i++) // Assuming Char1 to Char4
		{
			
			Node2D charNode = GetNode<Node2D>($"Char{i}");
			Character character = new Character();
			characters.Add(character);

			// Name Input
			LineEdit nameInput = charNode.GetNode<LineEdit>("VBoxContainer/LineEdit");
			nameInput.Connect("text_changed", Callable.From<string>((text) => character.Name = text));

			// Head
			Button headRight = charNode.GetNode<Button>("HBoxContainer/Button_HR");
			Button headLeft = charNode.GetNode<Button>("HBoxContainer/Button_HL");
			TextureRect headSprite = charNode.GetNode<TextureRect>("HBoxContainer/Head");

			headRight.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "Head", 1, headSprite)));
			headLeft.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "Head", -1, headSprite)));

			// Body
			Button bodyRight = charNode.GetNode<Button>("HBoxContainer2/Button_BR");
			Button bodyLeft = charNode.GetNode<Button>("HBoxContainer2/Button_BL");
			TextureRect bodySprite = charNode.GetNode<TextureRect>("HBoxContainer2/Body");

			bodyRight.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "Body", 1, bodySprite)));
			bodyLeft.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "Body", -1, bodySprite)));

			// Lower Body
			Button lowerBodyRight = charNode.GetNode<Button>("HBoxContainer3/Button_LR");
			Button lowerBodyLeft = charNode.GetNode<Button>("HBoxContainer3/Button_LL");
			TextureRect lowerBodySprite = charNode.GetNode<TextureRect>("HBoxContainer3/LowerBody");

			lowerBodyRight.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "LowerBody", 1, lowerBodySprite)));
			lowerBodyLeft.Connect("pressed", Callable.From(() => ChangeSprite(i - 1, "LowerBody", -1, lowerBodySprite)));
			
			GD.Print($"The value Chars is: {characters}");
			
		}
	}

	private string[] headSprites = { "res://Sprites/Head1.png", "res://Sprites/Head2.png", "res://Sprites/Head3.png" };
	private string[] bodySprites = { "res://Sprites/Body1.png", "res://Sprites/Body2.png", "res://Sprites/Body3.png" };
	private string[] lowerBodySprites = { "res://Sprites/LowerBody1.png", "res://Sprites/LowerBody2.png", "res://Sprites/LowerBody3.png" };
	

	private void ChangeSprite(int index, string type, int direction, TextureRect spriteNode)
{
	GD.Print($"The value is: {direction}");
	string[] spriteArray = type == "Head" ? headSprites :
						   type == "Body" ? bodySprites :
						   lowerBodySprites;

	string currentSprite = characters[index].GetSprite(type);
	int currentIndex = GetSpriteIndex(currentSprite, spriteArray);
	currentIndex = (currentIndex + direction + spriteArray.Length) % spriteArray.Length;

	string newSprite = spriteArray[currentIndex];
	characters[index].SetSprite(type, newSprite);
	
	spriteNode.Texture = GD.Load<Texture2D>(newSprite);
}


	private int GetSpriteIndex(string currentSprite, string[] spriteArray)
	{
		for (int i = 0; i < spriteArray.Length; i++)
		{
			if (spriteArray[i] == currentSprite)
				return i;
		}
		return 0;
	}
}

public class Character
{
	public string Name { get; set; } = "Default";
	public string HeadSprite { get; set; } = "res://Sprites/Head1.png";
	public string BodySprite { get; set; } = "res://Sprites/Body1.png";
	public string LowerBodySprite { get; set; } = "res://Sprites/LowerBody1.png";

	// Instead of using "ref", we use a method to set the value
	public void SetSprite(string type, string spritePath)
	{
		if (type == "Head") HeadSprite = spritePath;
		else if (type == "Body") BodySprite = spritePath;
		else if (type == "LowerBody") LowerBodySprite = spritePath;
	}

	public string GetSprite(string type)
	{
		return type == "Head" ? HeadSprite :
			   type == "Body" ? BodySprite :
			   LowerBodySprite;
	}
}
