---
external help file: PSWorkItem-help.xml
Module Name: PSWorkItem
online version: https://bit.ly/3cUDMOX
schema: 2.0.0
---

# Complete-PSWorkItem

## SYNOPSIS

Mark a PSWorkItem as complete.

## SYNTAX

```yaml
Complete-PSWorkItem [-ID] <Int32> [-Path <String>] [-CompletionDate <DateTime>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

When you are ready to mark a task as complete, use this command. Complete-PSWorkItem will set the progress to 100, mark the item as completed, copy it to the Archive table, and delete it from the tasks table. There are no commands to modify the task after it has been marked as completed so if you need to update the category, name, or description, do so before completing it.

## EXAMPLES

### Example 1

```powershell
PS C:\> Complete-PSWorkItem -id 9 -PassThru

    Database: C:\Users\Jeff\PSWorkItem.db
ID Name           Description Category Completed
-- ----           ----------- -------- ---------
6  Clean database             Other    7/30/2023 10:40:48 AM
```

Mark a PSWorkItem as completed and move it to the Archive table. The PSWorkItem will most likely get a new ID. The item will be deleted from the Tasks table.

### Example 2

```powershell
PS C:\> Get-PSWorkItem -category Alpha | Complete-WorkItem
```

Complete all work items from the Alpha category.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the command.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ID

The PSWorkItem ID. The task will get a new ID in the Archive table.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

The path to the PSWorkItem SQLite database file.
It should end in .db

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $PSWorkItemPath
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the command runs.
The command is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompletionDate

Specify the completion date. The default is now.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Int32

## OUTPUTS

### None

### PSWorkItemArchive

## NOTES

This command has an alias of cwi.

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-PSWorkItemArchive](Get-PSWorkItemArchive.md)

[Remove-PSWorkItem](Remove-PSWorkItem.md)

[Set-PSWorkItem](Set-PSWorkItem.md)
