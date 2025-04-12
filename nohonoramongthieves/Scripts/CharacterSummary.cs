using Godot;
using System;

public partial class CharacterSummary : Node
{
	private Button _nextButton;
	
	
	public override void _Ready()
	{
		_nextButton = GetNode<Button>("Next");
		_nextButton.Pressed += () => OnNextButtonPressed();
	}
	
	private void OnNextButtonPressed()
	{
		SceneManager.Instance.NextScene();
	}
		

}
