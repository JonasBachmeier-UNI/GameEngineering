using Godot;

public partial class CharacterDisplay : Node2D
{
	[Export] public int CharacterIndex = 0; // Character slot index
	private TextureRect headSprite, bodySprite, topSprite;
	
	private float breathTime = 0f;
	private float breathAmplitude = 1.5f;
	private float breathSpeed = 1.0f; 
	private Vector2 headBasePos, bodyBasePos, topBasePos;

	public override void _Ready()
	{
		// Get references to sprite nodes
		headSprite = GetNode<TextureRect>("HeadSprite");
		bodySprite = GetNode<TextureRect>("BodySprite");
		topSprite = GetNode<TextureRect>("TopSprite");

		// Load the character from GlobalCharacterManager
		LoadCharacter(CharacterIndex);

		headBasePos = headSprite.Position;
		bodyBasePos = bodySprite.Position;
		topBasePos = topSprite.Position;
	}
	
	public override void _Process(double delta)
	{
		if (headSprite == null || topSprite == null)
			return;

		breathTime += (float)delta;

		// Smooth downward breathing with sine wave (negative offset)
		float offsetY = Mathf.Cos(breathTime * breathSpeed * Mathf.Tau) * breathAmplitude;

		// Move Head and Top down (negative offset)
		headSprite.Position = headBasePos + new Vector2(0, -offsetY);
		topSprite.Position = topBasePos + new Vector2(0, -offsetY);
	}

	public void LoadCharacter(int index)
	{
		Character character = GlobalCharacterManager.Instance.GetCharacterByRealId(index);

		// Load sprite textures
		headSprite.Texture = GD.Load<Texture2D>(character.HeadSprite);
		bodySprite.Texture = GD.Load<Texture2D>(character.BodySprite);
		topSprite.Texture = GD.Load<Texture2D>(character.TopSprite);
		

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
		}
	}
}
