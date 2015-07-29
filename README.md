# Work in Progress

This project is under development.

# TaskHandler

Handle tasks or todos by command line.

## Usage

### Show task list that are not closed

Just run `th` command.

```
th
```

### Show all tasks including closed one

Run `th` command with -a option.

```
th -a
```

### Add task

Run `th add` command and pass arguments like below. The task will be added to project file.

```
th add project_name task_name due_date
```

### Delete task

Run `th del` command and pass arguments like below. Specified task will be removed from project file.

```
th del task_number
```

### Close task

Run `th close` command and pass arguments like below. Specified task will be closed.

```
th close task_number
```

### Open task

Run `th open` command and pass arguments like below. Specified task will be opened.

```
th open task_number
```

### Show stats

Run `th stats` command.

```
th stats
```
