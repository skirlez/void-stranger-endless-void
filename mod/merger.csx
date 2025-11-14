using UndertaleModLib.Models;
using UndertaleModLib.Util;
using UndertaleModLib.Decompiler;

// A script to merge Void Stranger and the level editor, Endless Void.
// Scripts used for reference:
// ImportGraphics.csx

EnsureDataLoaded();

string runningDirectory = Path.GetDirectoryName(ScriptPath);

string endlessVoidPatchesPath = Path.GetFullPath(Path.Combine(runningDirectory, "..", "..", "patches"));
string endlessVoidDataPath = Path.GetFullPath(Path.Combine(runningDirectory, "..", "data.win"));

int stringListLength = Data.Strings.Count;

UndertaleData endlessVoidData = UndertaleIO.Read(new FileStream(endlessVoidDataPath, FileMode.Open, FileAccess.Read));

uint addInstanceId = Data.GeneralInfo.LastObj - 100000;
Data.GeneralInfo.LastObj += endlessVoidData.GeneralInfo.LastObj - 100000;

int lastTexturePage = Data.EmbeddedTextures.Count - 1;
int lastTexturePageItem = Data.TexturePageItems.Count - 1;

Dictionary<UndertaleEmbeddedTexture, int> dict = new Dictionary<UndertaleEmbeddedTexture, int>();
foreach (UndertaleEmbeddedTexture embeddedTexture in endlessVoidData.EmbeddedTextures) {
	if (embeddedTexture.TextureInfo.Name.Content == "VoidStrangerTextureGroup" || 
			embeddedTexture.TextureInfo.Name.Content == "__YY__0fallbacktexture.png_YYG_AUTO_GEN_TEX_GROUP_NAME_")
		continue;

	UndertaleEmbeddedTexture newTexture = new UndertaleEmbeddedTexture();
	lastTexturePage++;
	newTexture.Name = new UndertaleString("Texture " + lastTexturePage);
	newTexture.TextureData.Image = embeddedTexture.TextureData.Image;
	Data.EmbeddedTextures.Add(newTexture);

	dict.Add(embeddedTexture, lastTexturePage);
}

foreach (UndertaleSprite sprite in endlessVoidData.Sprites) {
	if (sprite.Textures[0].Texture == null) // not present when building with NoVoidStrangerGroups config
		continue;
	if (sprite.Textures[0].Texture.TexturePage.TextureInfo.Name.Content == "VoidStrangerTextureGroup")
		continue;
	Data.Sprites.Add(sprite);
	foreach (UndertaleSprite.TextureEntry textureEntry in sprite.Textures) {
		int newIndex = dict[textureEntry.Texture.TexturePage];
		textureEntry.Texture.TexturePage = Data.EmbeddedTextures[newIndex];
		lastTexturePageItem++;
		textureEntry.Texture.Name = new UndertaleString("PageItem " + lastTexturePageItem);
		Data.TexturePageItems.Add(textureEntry.Texture);
	}
}


foreach (UndertaleSound sound in endlessVoidData.Sounds) {
	if (sound.AudioGroup.Name.Content == "audiogroup_void_stranger")
		continue;
	sound.AudioGroup = Data.AudioGroups[0]; 
	Data.Sounds.Add(sound);
	Data.EmbeddedAudio.Add(sound.AudioFile);
}

foreach (UndertaleCode code in endlessVoidData.Code)
	Data.Code.Add(code);

foreach (UndertaleFunction function in endlessVoidData.Functions) {
	Data.Functions.Add(function);
	function.NameStringID += stringListLength;
}

foreach (UndertaleVariable variable in endlessVoidData.Variables) {
	Data.Variables.Add(variable);

	if (variable.VarID == variable.NameStringID && variable.VarID != 0)
		variable.VarID += stringListLength;
	
	variable.NameStringID += stringListLength;
	
}
Data.InstanceVarCount += endlessVoidData.InstanceVarCount;
Data.InstanceVarCountAgain += endlessVoidData.InstanceVarCountAgain;
Data.MaxLocalVarCount = Math.Max(Data.MaxLocalVarCount, endlessVoidData.MaxLocalVarCount);

foreach (UndertaleCodeLocals locals in endlessVoidData.CodeLocals) 
	Data.CodeLocals.Add(locals);
foreach (UndertaleScript script in endlessVoidData.Scripts) 
	Data.Scripts.Add(script);


foreach (UndertaleGameObject gameObject in endlessVoidData.GameObjects) {
	if (!gameObject.Name.Content.StartsWith("obj_ev_"))
		continue;
	UndertaleGameObject parent = gameObject.ParentId;
	if (parent != null) {
		UndertaleGameObject parentFromVS = Data.GameObjects.ByName(parent.Name.Content);
		if (parentFromVS != null) {
			gameObject.ParentId = parentFromVS;
		}
	}
	Data.GameObjects.Add(gameObject);
}

foreach (UndertaleRoom room in endlessVoidData.Rooms) {
	Data.Rooms.Add(room);
	foreach (UndertaleRoom.Layer layer in room.Layers) {
		if (layer.LayerType == UndertaleRoom.LayerType.Instances) {
			foreach (UndertaleRoom.GameObject gameObject in layer.InstancesData.Instances)
				gameObject.InstanceID += addInstanceId;
		}
	}
}



foreach (UndertaleAnimationCurve curve in endlessVoidData.AnimationCurves)
	Data.AnimationCurves.Add(curve);


foreach (UndertaleResourceById<UndertaleRoom, UndertaleChunkROOM> room in endlessVoidData.GeneralInfo.RoomOrder)
	Data.GeneralInfo.RoomOrder.Add(room);

Data.GeneralInfo.FunctionClassifications |= endlessVoidData.GeneralInfo.FunctionClassifications;

foreach (UndertaleGlobalInit script in endlessVoidData.GlobalInitScripts)
	Data.GlobalInitScripts.Add(script);

foreach (UndertaleString str in endlessVoidData.Strings)
	Data.Strings.Add(str);

Data.GeneralInfo.Info |= UndertaleGeneralInfo.InfoFlags.ShowCursor;
Data.Options.Info |= UndertaleOptions.OptionsFlags.ShowCursor;

// Apply the patches

string[] files = Directory.GetFiles(endlessVoidPatchesPath);

foreach (string file in files) {
	if (Path.GetExtension(file) == ".gml") {
		string codeEntryName = Path.GetFileNameWithoutExtension(file);
		string patches = File.ReadAllText(file);
		applyPatches(codeEntryName, patches);
	}
}

void applyPatches(string codeEntryName, string patches) {
	UndertaleCode entry = Data.Code.ByName(codeEntryName);
	string targetPattern = @"// TARGET: ([^\n\r]+)";
	string[] sections = Regex.Split(patches, targetPattern);

	for (int i = 1; i < sections.Length; i += 2) {
		string code = GetDecompiledText(entry);
		string target = sections[i];
		string patch = sections[i + 1].Trim();
		string finalResult;
		switch (target) {
			case "TAIL":
				finalResult = code + "\n" + patch;
				break;
			case "HEAD": 
				finalResult = patch + "\n" + code;
				break;
			case "REPLACE":
				finalResult = patch;
				break;
			case "STRING":
				string[] parts = patch.Split('>');
				finalResult = code.Replace(parts[0], parts[1]);
				break;
			case "LINENUMBER_REPLACE": 
				int firstNewline = patch.IndexOf("\n");
				int insertPosition = int.Parse(patch.Substring(2, firstNewline - 1));
				string[] lines = code.Split('\n');
				lines[insertPosition - 1] = patch.Substring(firstNewline);
				finalResult = string.Join("\n", lines);
				break;
			case "LINENUMBER": 
				firstNewline = patch.IndexOf("\n");
				insertPosition = int.Parse(patch.Substring(2, firstNewline - 1));
				lines = code.Split('\n');
				lines[insertPosition - 1] = patch.Substring(firstNewline) + "\n" + lines[insertPosition - 1];
				finalResult = string.Join("\n", lines);
				break;
			default:
				finalResult = code;
				break;
		};
		ImportGMLString(codeEntryName, finalResult);
	}
}


Data.GeneralInfo.Name = endlessVoidData.GeneralInfo.Name;

//DisableAllSyncBindings();

ScriptMessage("Done! Endless Void has been merged!");