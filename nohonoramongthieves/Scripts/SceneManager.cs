using Godot;
using System;
using System.Collections.Generic;

public partial class SceneManager : Node
{
	private Godot.Collections.Array<string> scenePaths = new();
	private int _currentSceneIndex = 0;
	private int _participantNumber = 0;
	private bool _isPathsInitialized = false;
	
	private const string PARTICIPANT_ENTRY_SCENE = "res://scenes/ParticipantNumber.tscn";
	private const string CHARACTER_CREATION_SCENE = "res://scenes/CharacterCreation.tscn";
	private const string CHARACTER_SUMMARY_SCENE = "res://scenes/CharacterSummary.tscn";
	private const string FIGHT_SCENE = "res://scenes/test.tscn";
	private const string IN_BETWEEN_SCENE = "res://scenes/InBetweenScene.tscn";

	// Singleton
	public static SceneManager Instance;

	public override void _Ready()
	{
		// Initialize singleton
		if (Instance == null)
		{
			Instance = this;
		}
		else
		{
			QueueFree();
		}

		scenePaths.Add(PARTICIPANT_ENTRY_SCENE);

		if (scenePaths.Count == 0)
		{
			GD.PrintErr("SceneManager: No scenes assigned to scenePaths!");
			return;
		}

		_currentSceneIndex = 0;
		LoadScene(scenePaths[_currentSceneIndex]);
	}
	
	public void SetParticipantNumber(int participantNumber)
	{
		_participantNumber = participantNumber;
		InitializeScenePaths();
		
		NextScene();
	}
	
	private void InitializeScenePaths()
	{
		if (_isPathsInitialized)
			return;
			
		scenePaths.Clear();
		
		scenePaths.Add(CHARACTER_CREATION_SCENE);
		scenePaths.Add(CHARACTER_SUMMARY_SCENE);
		//scenePaths.Add(FIGHT_SCENE);
		
		List<int> scenarioOrder = GenerateScenarioOrder(_participantNumber);
		
		foreach (int scenarioId in scenarioOrder)
		{
			scenePaths.Add($"{IN_BETWEEN_SCENE}?scenario={scenarioId}");
			//scenePaths.Add(FIGHT_SCENE);
		}
		
		_isPathsInitialized = true;
		_currentSceneIndex = -1;
	}
	
	private List<int> GenerateScenarioOrder(int participantNumber)
	{
		List<List<int>> allSequences = new List<List<int>>
			{
				new List<int> {0, 1, 2, 3},
				new List<int> {0, 1, 3, 2},
				new List<int> {0, 2, 1, 3},
				new List<int> {0, 2, 3, 1},
				new List<int> {0, 3, 1, 2},
				new List<int> {0, 3, 2, 1},
				new List<int> {1, 0, 2, 3},
				new List<int> {1, 0, 3, 2},
				new List<int> {1, 2, 0, 3},
				new List<int> {1, 2, 3, 0},
				new List<int> {1, 3, 0, 2},
				new List<int> {1, 3, 2, 0},
				new List<int> {2, 0, 1, 3},
				new List<int> {2, 0, 3, 1},
				new List<int> {2, 1, 0, 3},
				new List<int> {2, 1, 3, 0},
				new List<int> {2, 3, 0, 1},
				new List<int> {2, 3, 1, 0},
				new List<int> {3, 0, 1, 2},
				new List<int> {3, 0, 2, 1},
				new List<int> {3, 1, 0, 2},
				new List<int> {3, 1, 2, 0},
				new List<int> {3, 2, 0, 1},
				new List<int> {3, 2, 1, 0}
			};
		
		return allSequences[participantNumber];
	}
	
	public int GetCurrentScenarioId()
	{
		string currentPath = scenePaths[_currentSceneIndex];
		if (currentPath.StartsWith(IN_BETWEEN_SCENE) && currentPath.Contains("?scenario="))
		{
			string scenarioParam = currentPath.Split("?scenario=")[1];
			if (int.TryParse(scenarioParam, out int scenarioId))
			{
				return scenarioId;
			}
		}
		return -1;
	}

	private void LoadScene(string scenePath)
	{
		if (string.IsNullOrEmpty(scenePath))
		{
			GD.PrintErr("LoadScene: scenePath is empty or null!");
			return;
		}
		
		var error = Error.Failed;
		
		if (scenePath.StartsWith(IN_BETWEEN_SCENE) && scenePath.Contains("?scenario="))
		{
			string scenarioPath = scenePath.Split("?scenario=")[0];
			error = GetTree().ChangeSceneToFile(scenarioPath);
		} else {
			error = GetTree().ChangeSceneToFile(scenePath);
		}
			

		 

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
