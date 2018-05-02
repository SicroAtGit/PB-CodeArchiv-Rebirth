# Conecpt

	Detailed informations about the PureBasic-CodeArchiv-Rebirth

## Add new code to the archive

- License choice of codes should not be restricted

- Only codes from the forums or other sources should be included which don't have a very short update cycle but haven't been modified for a while (3 months?) and can therefore be regarded as stable.

- All files that aren't in binary format must have a blank line at the end of the file (some Linux programs require this to work correctly)

- Don't include code files with too large resource files in the archive (larger than 5 megabytes?)

- When must the file extension be `.pb` and when `.pbi`?

	- `.pb` (PureBasic code file) should only be used for codes that can' t be used as include files. They contain code that is executed directly. Suitable e.g. for IDE tools.
	
	- `.pbi` (PureBasic include file) should only be used for code that doesn't contain code that is executed directly. All commands should be encapsulated in procedures, like libraries (`.dll` (Windows), `.so` (Linux) and `.dylib` (Mac)).
		
		However, an example code can be written within a `CompilerIf #PB_Compiler_MainFile` block. This will only execute the code if the `.pbi` file is executed directly (not included).
	
- Code is a single file:

	- Code must follow the template:
	
			;   Description:
			;            OS: Windows, Linux, Mac
			; English-Forum:
			;  French-Forum:
			;  German-Forum:
			; -----------------------------------------------------------------------------

			; Copyright and license text

			From here follows the Purebasic code.
			
	- Storage location for the code file:

			/Categorie/CodeName[Win,Lin,Mac].[pb|pbi]
			
		Examples:
		
			/Gadget/HTML-Editor[Win,Lin].pbi
			/Gadget/HTML-Editor[Win].pbi
			/Gadget/HTML-Editor.pbi
			
		This is unnecessary and forbidden:
		
			/Gadget/HTML-Editor[Win,Lin,Mac]
			
- Code has more than one file:

	- Storage location for the code files:
	
		- `/Categorie/CodeName[Win,Lin]/`
		
			- This directory must contain:
			
				- `/Categorie/CodeName/CodeInfo.txt` --- Look at the template:
				
						;   Description:
						;            OS: Windows, Linux, Mac
						; English-Forum:
						;  French-Forum:
						;  German-Forum:
				
				- `/Categorie/CodeName/License.txt`
				
				- Files belonging to the code (subdirectories of any depth are allowed)
				
## Repo-Tools

### [CodeCleaner](https://github.com/Seven365/PureBasic-CodeArchiv-Rebirth/blob/repo-dev/CodesCleaner.pb) (outdated)

This tool is the first tool to run on new codes.

- Removes the IDE options at the end of each code file (`.pb` and `.pbi`)

### [CodeChecker](https://github.com/Seven365/PureBasic-CodeArchiv-Rebirth/blob/repo-dev/CodesChecker.pb)  (outdated)

This tool is the second tool that should be executed on new codes.

- Considers the following files: `.pb`, `.pbi` and `CodeInfo.txt`.
	`License.txt` exists only since the recent rebuilding of the CodeArchive and is therefore not considered by the outdated tool.

- Performs a syntax check with the PB compiler: `pbcompiler --check --thread "CodeFilePath"`

- Checks if `.pbi` files contain a `CompilerIf #PB_Compiler_MainFile` block
	
	It would have been better if the tool checked if there was code outside of procedures, but I wanted to keep programming the tool simple.

- Checks only codes that support the current operating system
	
	Which operating system the codes support is taken from the CodeName: `CodeName[Win,Lin,Mac]`

- Checks if all code header fields have been filled in correctly
	
	- For the date field, the format is also checked: `#####-##-##-##` (# = one-digit number (0-9))
	
- Errors are written to text files stored in the temporary directory `GetTemporaryDirectory()`:
	
	`CompilerErrors.txt`, `CodeHeaderErrors.txt` and `FileNameErrors.txt`

### [Code_formatting_helper](https://github.com/Seven365/PureBasic-CodeArchiv-Rebirth/blob/repo-dev/Code_formatting_helper.pb)  (outdated)

This tool helps to format new codes by providing easy-to-understand input fields and checkboxes for filling in and activating them.

For example, it is easy to specify the operating system support using checkboxes. The required `CompilerIf #PB_Compiler_OS ...` queries are then automatically created by the tool that prevent the code from running on unsupported operating systems.

There are also separate input fields for the main code and the example code. The example code is automatically written to a `CompilerIf #PB_Compiler_MainFile` block by the tool.

The tool will be replaced by a template code file. This should be enough and is much less complicated.

### [Forum-Codes-Updates-Checker](https://github.com/Seven365/PureBasic-CodeArchiv-Rebirth/tree/repo-dev/Forum-Codes-Updates-Checker) (outdated)

This tool helps to keep the codes in the archive up-to-date without manually checking the codes in the forums.

1. It reads the forum URLs from the code header of the file (`.pb`, `.pbi` and `.txt` (`CodeInfo.txt`))
2. From all found URLs the HTML code will be downloaded
3. In each HTML code, the tool searches for the first find of the thread post editing note and reads this note. In addition, the number of posts is read from the thread.
	
	RegEx for thread post editing note: `(Zuletzt geändert von|Last edited by)\s+.*\s+(am|on)\s+(?<time>.*)`
	
	RegEx for number of posts: `[0-9]+\s+(Beiträge|Beitrag|posts|post)`
	
	The result looks like this, for example (English forum):

		EditDateInFirstPost: Thu Jul 21, 2016 9:52 pm
		CountOfPosts: 199 posts

	or like this (German forum):

		EditDateInFirstPost: 23.09.2015 20:50
		CountOfPosts: 10 Beiträge

4. This information is compared with the information in a cache file. If the cache file does not yet exist, it is simply compared with an empty string.
	The name of the cache file is the SHA1 hash of the forum thread URL.
	If the two information sources have different information, an entry is created in a todo list:

		Path to the code file on the local computer
		:::
		Forum thread URL
		EditDateInFirstPost: Thu Jul 21, 2016 9:52 pm
		CountOfPosts: 199 posts

	After that, the content in the cache file will be updated.
5. After all this, the ToDo list is saved to the file `ToDo.txt` in the directory `#PB_Compiler_FilePath`.

If there are no cache files, the tool evaluates all local codes outdated and the codes in the forums newer.

## What is the workflow with Git and Github?

The old workflow is described here: [Old `README.md` from the orphaned `repo-dev` branch](https://github.com/Seven365/PureBasic-CodeArchiv-Rebirth/tree/repo-dev) 

However, this workflow is no longer correct and must be revised, because no `next` branch exists with the new workflow. A new workflow is created as soon as the work on the repo tools is completed.

### Are there already thoughts about the new workflow?

#### What should the commit description look like?

	Commit title

	Commit description
The commit title and commit description should be separated by a blank line. This is the usual procedure for git and `git log --oneline` then correctly displays only the commit titles without the commit description.

##### Commit title

The commit title shouldn't exceed 71 characters and should only consist of one line. Guides on the Internet recommend even fewer characters (52 for example), but I often feel that too little.

Github still displays commit titles with a length of 71 characters. If the commit title consists of more than 71 characters, Github doesn't display the commit title completely, so that the `[...]` button must be clicked. Ideally, this button should only be clicked if the commit description is to be displayed.

Don't write the commit title in the past tense, but in the present tense:

	Add function 'x'

instead of

	Added function 'x'

##### Commit description

The commit description can consist of several lines, but shouldn't contain more than 71 characters per line.

Don't describe in the commit description what your commit changes --- this can be easily found out via `git show commit-hash`. It is more helpful if the commit description states why the changes were made.

- If an error is fixed with the commit --- Which error? Does this lead to new errors?

- Is a new function implemented by the commit --- What does the new function do?

- Does the commit improve things --- What does it do better?

#### Branch model and integration to the `master` branch

Since the recent rebuilding of the CodeArchive, merge commits aren't used, because the commits display at Github with merge commits looks unclean.

For changes, a branch based on the branch `master` is created locally each time. No commits are created directly in the `master` branch.

Once the work is complete, the branch is uploaded to your own public repository fork and a pull request is submitted to the original repository.

Maybe some corrections will follow until the maintainers are satisfied. For example, only changes described in the commit description should be included in the commits. Maybe there are commits in the branch that should be combined into a single commit. And so on.

At the end, the branch is inserted from the pull request to the top of the `master` banch via `git merge --ff-only changes-branch`.
				
## Ideas that maybe won't be implemented

- For each command of the codes, a description in the style of the PB help
	
	With this small team, the implementation would be too much work.
