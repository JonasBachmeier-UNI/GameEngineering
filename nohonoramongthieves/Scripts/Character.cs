using Godot;
using System;

public partial class Character
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

		HeadGradientColor = Colors.White;
		BodyGradientColor = Colors.White;
		TopGradientColor = Colors.White;
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
	
	public GradientTexture1D CreateGradient(Color selectedColor)
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
}
