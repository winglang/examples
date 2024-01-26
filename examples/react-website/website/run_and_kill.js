const { spawn } = require('child_process');
const kill = require('tree-kill');

// Function to start a process and kill it after a specified duration
function runAndKillAfter(command, args, duration) {
    const process = spawn(command, args);

    console.log(`Process started with PID: ${process.pid}`);

    setTimeout(() => {
        console.log(`Killing process with PID: ${process.pid}`);
        const foo = kill(process.pid)
        console.log({foo});
        console.log(`Process killed after ${duration} milliseconds`);
    }, duration);
}

console.log('Starting process...');
runAndKillAfter('react-scripts', ['build'], 60000); // 60000 milliseconds = 60 seconds
