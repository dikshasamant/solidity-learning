// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract TodoList {

    struct Task {
        uint256 id;
        string title;
        bool completed;
    }

    Task[] public tasks;

    mapping(uint256 => Task) public idToTask;

    uint256 public nextTaskId = 1;

    function addTask(string memory _title) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        Task memory newTask = Task(nextTaskId ,_title, false);
        tasks.push(newTask);
        idToTask[nextTaskId] = newTask;
        nextTaskId++;
    }

    function getTask(uint256 _taskid) public view returns (Task memory) {
        require(idToTask[_taskid].id != 0, "Task does not exist");
        return idToTask[_taskid];
    }

    function getAllTasks() public view returns (Task[] memory) {
        return tasks;
    }

    function taskCount() public view returns (uint256) {
        return tasks.length;
    }

    function completeTask(uint256 _taskId) public {
        require(idToTask[_taskId].id != 0, "Task does not exist");
        require(idToTask[_taskId].completed == false, "Task already completed");
        idToTask[_taskId].completed = true;
        for (uint256 i = 0; i < tasks.length; i++) 
        {
            if (tasks[i].id == _taskId)
            {
                tasks[i].completed = true;
                break;
            }
        }
    }

    function updateTaskTitle(uint256 _taskId, string memory _newTitle) public {
        require(idToTask[_taskId].id != 0, "Task does not exist");
        require(bytes(_newTitle).length > 0, "Title cannot be empty");
        idToTask[_taskId].title = _newTitle;
        for (uint256 i = 0; i < tasks.length; i++)
        {
            if (tasks[i].id == _taskId)
            {
                tasks[i].title = _newTitle;
                break;
            }
        }
    }

    function deleteTask(uint256 _taskId) public {
        require(idToTask[_taskId].id != 0, "Task does not exist");
        delete idToTask[_taskId];
        for (uint256 i = 0; i < tasks.length; i++)
        {
            if (tasks[i].id == _taskId)
            {
                tasks[i] = tasks[tasks.length - 1];
                tasks.pop();
                break;
            }
        }
    }


}