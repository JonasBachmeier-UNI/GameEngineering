using Godot;
using System.Collections.Generic;

public partial class CharacterManager : Control
{
	private List<Character> characters = new List<Character>();

	private string[] headSprites = { "res://Sprites/Head1.png", "res://Sprites/Head2.png", "res://Sprites/Head3.png", "res://Sprites/Head4.png", "res://Sprites/Head5.png" };
	private string[] bodySprites = { "res://Sprites/Body1.png", "res://Sprites/Body2.png", "res://Sprites/Body3.png", "res://Sprites/Body4.png" };
	private string[] topSprites = { "res://Sprites/Top1.png", "res://Sprites/Top2.png", "res://Sprites/Top3.png", "res://Sprites/Top4.png", "res://Sprites/Top5.png", "res://Sprites/Top6.png", "res://Sprites/Top7.png" };

	public override void _Ready()
	{
		for (int i = 0; i < 3; i++) 
		{
			Node2D charNode = GetNode<Node2D>($"Char{i + 1}");
			Character character = new Character
			{
				HeadSprite = headSprites[0],
				BodySprite = bodySprites[0],
				TopSprite = topSprites[0]
			};
			characters.Add(character);
			GD.Print($"Final character count: {characters.Count}");
			
			
			// Name Input
			LineEdit nameInput = charNode.GetNode<LineEdit>("VBoxContainer/LineEdit");
			nameInput.Connect("text_changed", Callable.From<string>((text) => character.Name = text));
			
			//Shader Colors
			ColorPickerButton topColorPicker  = charNode.GetNode<ColorPickerButton>("HBoxContainer0/ColorPickerButton");
			ColorPickerButton headColorPicker = charNode.GetNode<ColorPickerButton>("HBoxContainer1/ColorPickerButton");
			ColorPickerButton bodyColorPicker = charNode.GetNode<ColorPickerButton>("HBoxContainer2/ColorPickerButton");
			
			
			
			// Top Section
			TextureRect topSprite = charNode.GetNode<Container>("Container").GetNode<TextureRect>("Top");
			topSprite.Texture = GD.Load<Texture2D>(character.TopSprite);

			Button topRight = charNode.GetNode<Button>("HBoxContainer0/Button_LR");
			Button topLeft = charNode.GetNode<Button>("HBoxContainer0/Button_LL");

			topRight.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id"), "Top", 1, topSprite)));
				
			
			topLeft.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id") , "Top", -1, topSprite)));

			GD.Print($"The value Chars is: {characters}");

			// Head Section
			TextureRect headSprite = charNode.GetNode<Container>("Container").GetNode<TextureRect>("Head");
			headSprite.Texture = GD.Load<Texture2D>(character.HeadSprite);

			Button headRight = charNode.GetNode<Button>("HBoxContainer1/Button_HR");
			Button headLeft = charNode.GetNode<Button>("HBoxContainer1/Button_HL");

			headRight.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id") , "Head", 1, headSprite)));
			headLeft.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id") , "Head", -1, headSprite)));

			// Body Section
			TextureRect bodySprite = charNode.GetNode<Container>("Container").GetNode<TextureRect>("Body");
			bodySprite.Texture = GD.Load<Texture2D>(character.BodySprite);

			Button bodyRight = charNode.GetNode<Button>("HBoxContainer2/Button_BR");
			Button bodyLeft = charNode.GetNode<Button>("HBoxContainer2/Button_BL");

			bodyRight.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id") , "Body", 1, bodySprite)));
			bodyLeft.Connect("pressed", Callable.From(() => ChangeSprite((int) charNode.GetMeta("id") , "Body", -1, bodySprite)));

			headColorPicker.Connect("color_changed", Callable.From<Color>((Color newColor) => 
				ChangeGradient((int) charNode.GetMeta("id"), "Head", newColor, headSprite)
			));

			bodyColorPicker.Connect("color_changed", Callable.From<Color>((Color newColor) => 
				ChangeGradient((int) charNode.GetMeta("id"), "Body", newColor, bodySprite)
			));

			topColorPicker.Connect("color_changed", Callable.From<Color>((Color newColor) => 
				ChangeGradient((int) charNode.GetMeta("id"), "Top", newColor, topSprite)
			));
		}
		
		Button nextSceneButton = GetNode<Button>("NextSceneButton");
		nextSceneButton.Connect("pressed", Callable.From(SaveAndGoToNextScene));
	}

private void SaveAndGoToNextScene()
	{
		for (int i = 0; i < characters.Count; i++)
		{
			GlobalCharacterManager.Instance.SaveCharacter(i, characters[i]);
		}
		
		for (int i = 0; i < GlobalCharacterManager.Instance.Characters.Count ; i++) {
		}
		

		SceneManager.Instance.NextScene();
	}

private void ChangeSprite(int index, string type, int direction, TextureRect spriteNode)
	{
		string[] spriteArray = type == "Head" ? headSprites :
							   type == "Body" ? bodySprites :
							   type == "Top" ? topSprites :
							   null;

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


private void ChangeGradient(int index, string type, Color newColor, TextureRect spriteNode)
{
	if (index < 0 || index >= characters.Count) {
		GD.Print("Aborting");
		return;
		}


	if (type == "Head")
		characters[index].HeadGradientColor = newColor;
	else if (type == "Body")
		characters[index].BodyGradientColor = newColor;
	else if (type == "Top")
		characters[index].TopGradientColor = newColor;
		
	// Update the shader uniform if the material is ShaderMaterial.
	if (spriteNode.Material is ShaderMaterial shaderMat)
	{
		shaderMat.SetShaderParameter("gradient", characters[index].GetGradient(type));
	}
}
}

/*
public class Character
{
	public string Name { get; set; } = "Default";
	public string HeadSprite { get; set; }
	public string BodySprite { get; set; }
	public string TopSprite { get; set; }

	public Color HeadGradientColor { get; set; } = new Color(1, 1, 1, 1);
	public Color BodyGradientColor { get; set; } = new Color(1, 1, 1, 1);
	public Color TopGradientColor { get; set; } = new Color(1, 1, 1, 1);
	
	public Character(string name = "Unnamed")
	{
		Name = name;
		HeadSprite = "res://Sprites/Head1.png";
		BodySprite = "res://Sprites/Body1.png";
		TopSprite = "res://Sprites/Top1.png";

		HeadColor = Colors.White;
		BodyColor = Colors.White;
		TopColor = Colors.White;
	}

	public void SetSprite(string type, string spritePath)
	{
		if (type == "Head") HeadSprite = spritePath;
		else if (type == "Body") BodySprite = spritePath;
		else if (type == "Top") TopSprite = spritePath;
		
		GD.Print($"Updated {type} to {spritePath}");
	}

	public string GetSprite(string type)
	{
		return type == "Head" ? HeadSprite :
			   type == "Body" ? BodySprite :
			   type == "Top" ? TopSprite :
			   null;
	}

	public GradientTexture1D GetGradient(string type)
	{
		return type == "Head" ? CreateGradient(HeadGradientColor) :
			   type == "Body" ? CreateGradient(BodyGradientColor) :
			   type == "Top" ? CreateGradient(TopGradientColor) :
			   null;
	}
	
	private GradientTexture1D CreateGradient(Color selectedColor)
{
	float luminance = selectedColor.R * 0.299f + selectedColor.G * 0.587f + selectedColor.B * 0.114f;

	luminance = Mathf.Clamp(luminance, 0f, 1f);

	Gradient gradient = new Gradient();
	gradient.AddPoint(0.0f, new Color(0, 0, 0, 1));
	gradient.AddPoint(luminance, selectedColor);
	gradient.AddPoint(1.0f, new Color(1, 1, 1, 1));

	GradientTexture1D gradientTexture = new GradientTexture1D();
	gradientTexture.Gradient = gradient;

	return gradientTexture;
}

}*/
