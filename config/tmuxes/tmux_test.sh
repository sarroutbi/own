#!/bin/bash
tmux new -s test_session  -d
tmux source-file ~/tmuxes/.tmux.common.conf
tmux rename-window 'zero'
tmux new-window -t test_session:1 -n 'two'
tmux attach-session
