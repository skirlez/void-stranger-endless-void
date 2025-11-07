# Patches
These are patches to Void Stranger's code that are applied when the `merger.csx` script is ran. 

## For Contributors
Patches, in short, are a list of text modifications to a decompiled code file which are then recompiled.

A text modification is called a section. Sections start with a `"TARGET: "` string, and end at the next one or the end of the file.
Each section is processed in order, **and the file is recompiled with the new code for every section.**
There are an number of targets available to choose from:

- HEAD: Code will be placed at the very start
- TAIL: Code will be placed at the very end
- LINENUMBER: Code will be placed at the line number in the next line's comment.
It will do so by pushing the code already at that line number downwards, and copying the section's code above it.
- LINENUMBER_REPLACE: Code will be placed at the line number in the next line's comment, erasing the code previously at that line.
It will do so by removing that line, and copying the section's code to where it once was.
- REPLACE: Completely replaces the file's code with the section's code.
- STRING: Special target. Formatted like so:
```
x>y
```
or
```
x
>
y
```
will replace every sequence of characters matching x with y in the file.

When writing patches, please leave comments explaining what each section is responsible for. I didn't for a lot of them, and I had to work backwards to figure out what they did later.

Remember that each section's code should not be indented to match the original file. the UndertaleModTool compiler doesn't care about indenting, and it's a lot cleaner if you don't.

Unlike the main EV codebase, you don't have to use `asset_get_index`/`agi` when referencing assets in patches, since they are processed after EV is merged, and so the UndertaleModTool compiler will resolve the asset names correctly.

Remember to account for the fact that sections are processed individually! This means that if you have two LINENUMBER sections (operating on, in this case, an empty file), like so:
```
// TARGET: LINENUMBER
// 1
code
more code

// TARGET: LINENUMBER
// 2
even more code
even more more code
```
You may expect the result to be:

```
code
more code
even more code
even more more code
```
But it will actually be:

```
code
even more code
even more more code
more code
```

This problem can be avoided by ordering the LINENUMBER sections, from highest line number to lowest.

- TIP: You can use `exit` in scripts or `return` in functions to erase entire branches
- TIP 2: You can use LINENUMBER_REPLACE to delete single lines by replacing the line with a comment. (As for deleting regions... I've never actually needed to do that...)
