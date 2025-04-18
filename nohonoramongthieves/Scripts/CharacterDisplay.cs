using Godot;

public partial class CharacterDisplay : Node2D
{
	[Export] public int CharacterIndex = 0; // Character slot index
	private TextureRect headSprite, bodySprite, topSprite;

	public override void _Ready()
	{
		// Get references to sprite nodes
		headSprite = GetNode<TextureRect>("HeadSprite");
		bodySprite = GetNode<TextureRect>("BodySprite");
		topSprite = GetNode<TextureRect>("TopSprite");

		// Load the character from GlobalCharacterManager
		LoadCharacter(CharacterIndex);
		
		GD.Print("Available Nodes: ");
		foreach (Node child in GetChildren())
		{
			GD.Print(child.Name);
		}
	}

	public void LoadCharacter(int index)
	{
		if (!GlobalCharacterManager.Instance.HasCharacter(index))
		{
			GD.PrintErr($"Character at index {index} not found!");
			return;
		}

		Character character = GlobalCharacterManager.Instance.GetCharacter(index);

		// Load sprite textures
		headSprite.Texture = GD.Load<Texture2D>(character.HeadSprite);
		bodySprite.Texture = GD.Load<Texture2D>(character.BodySprite);
		topSprite.Texture = GD.Load<Texture2D>(character.TopSprite);
		
		GD.Print(character.HeadSprite);

		// Apply gradient colors
		ApplyGradient(headSprite, "Head", character);
		ApplyGradient(bodySprite, "Body", character);
		ApplyGradient(topSprite, "Top", character);
	}

	private void ApplyGradient(TextureRect sprite, string type, Character character)
	{
		ShaderMaterial _material;
		
		if (sprite.Material == null)
		{
			ShaderMaterial newMaterial = new ShaderMaterial();
			sprite.Material = newMaterial;
		}
		

		if (sprite.Material is ShaderMaterial sharedMaterial)
		{
			_material = (ShaderMaterial)sharedMaterial.Duplicate();
			sprite.Material = _material;
		}

		if (sprite.Material is ShaderMaterial shaderMat)
		{
			shaderMat.SetShaderParameter("gradient", character.GetGradient(type));
			GD.Print("Applying Shader " + character.GetGradient(type));
		}
	}
}
