using Godot;
using System;

public partial class SceneManager : Node
{
	// Store scene paths as strings
	private Godot.Collections.Array<string> scenePaths = new();

	private int _currentSceneIndex = 0;

	// Singleton
	public static SceneManager Instance;

	public override void _Ready()
	{
		// Initialize singleton instance
		if (Instance == null)
		{
			Instance = this;
		}
		else
		{
			QueueFree(); // Ensure only one instance exists
		}

		// Manually populate the scenePaths array with scene paths (strings)
		scenePaths.Add("res://Scenes/CharacterCreation.tscn");
		scenePaths.Add("res://Scenes/InBetweenScene.tscn");
		scenePaths.Add("res://Scenes/CharacterCreation.tscn");

		if (scenePaths.Count == 0)
		{
			GD.PrintErr("SceneManager: No scenes assigned to scenePaths!");
			return;
		}

		_currentSceneIndex = 0;
		LoadScene(scenePaths[_currentSceneIndex]);
	}

	private void LoadScene(string scenePath)
	{
		if (string.IsNullOrEmpty(scenePath))
		{
			GD.PrintErr("LoadScene: scenePath is empty or null!");
			return;
		}

		// Load the scene dynamically from the scene path
		var error = GetTree().ChangeSceneToFile(scenePath);

		if (error != Error.Ok)
		{
			GD.PrintErr("Failed to load scene: " + scenePath);
		}
	}

	public void NextScene()
	{
		if (_currentSceneIndex < scenePaths.Count - 1)
		{
			_currentSceneIndex++;
			LoadScene(scenePaths[_currentSceneIndex]);
		}
		else
		{
			GD.Print("SceneManager: No more scenes ahead.");
		}
	}

	public void PreviousScene()
	{
		if (_currentSceneIndex > 0)
		{
			_currentSceneIndex--;
			LoadScene(scenePaths[_currentSceneIndex]);
		}
		else
		{
			GD.Print("SceneManager: No previous scene.");
		}
	}
}
