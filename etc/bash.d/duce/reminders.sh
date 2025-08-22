# vim: ft=sh
# forked from bknopps
# 2025.08.22 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

reminders() {
    local reminders_version="2.0.0"
    local temp_reminders_file="/tmp/reminders_numbered.json"
    
    print_help() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_blue1
            printf "reminders"
            bd_ansi reset
            printf "\t${reminders_version}\n"
            printf "Terminal interface for macOS Reminders app\n\n"
            bd_ansi fg_yellow3
            printf "USAGE:\n"
            bd_ansi reset
            printf "\treminders [COMMAND] [OPTIONS]\n"
            bd_ansi fg_yellow3
            printf "COMMANDS:\n"
            bd_ansi fg_blue1
            printf "\tadd \"task\" [list]"
            bd_ansi reset
            printf "       Add a reminder to specified list (default: Reminders)\n"
            bd_ansi fg_blue1
            printf "\tdue \"task\" \"date\" [list]"
            bd_ansi reset
            printf " Add reminder with due date (YYYY-MM-DD or 'today'/'tomorrow')\n"
            bd_ansi fg_blue1
            printf "\tlist [list_name]"
            bd_ansi reset
            printf "        Show reminders from list (default: all incomplete)\n"
            bd_ansi fg_blue1
            printf "\tlists"
            bd_ansi reset
            printf "                   Show all reminder lists\n"
            bd_ansi fg_blue1
            printf "\tcomplete \"task\""
            bd_ansi reset
            printf "         Mark a reminder as complete\n"
            bd_ansi fg_blue1
            printf "\tcomplete [number]"
            bd_ansi reset
            printf "       Mark numbered reminder as complete\n"
            bd_ansi fg_blue1
            printf "\tdelete \"task\""
            bd_ansi reset
            printf "           Delete a reminder\n"
            bd_ansi fg_blue1
            printf "\tdelete [number]"
            bd_ansi reset
            printf "         Delete numbered reminder\n"
            bd_ansi fg_blue1
            printf "\tedit [number] \"new_text\""
            bd_ansi reset
            printf " Edit numbered reminder\n"
            bd_ansi fg_blue1
            printf "\tsearch \"text\""
            bd_ansi reset
            printf "           Search for reminders containing text\n"
            bd_ansi fg_blue1
            printf "\ttoday"
            bd_ansi reset
            printf "                   Show reminders due today or overdue\n"
            bd_ansi fg_blue1
            printf "\tclear-completed \"list\""
            bd_ansi reset
            printf "  Clear all completed reminders from a list\n"
            bd_ansi fg_blue1
            printf "\t-h|--help"
            bd_ansi reset
            printf "               Show this help\n"
            bd_ansi fg_yellow3
            printf "EXAMPLES:\n"
            bd_ansi reset
            printf "\treminders add \"Buy groceries\"\n"
            printf "\treminders add \"Review PR\" Work\n"
            printf "\treminders due \"Meeting with team\" tomorrow Work\n"
            printf "\treminders due \"Project deadline\" 2025-08-25\n"
            printf "\treminders list Work\n"
            printf "\treminders today\n"
            printf "\treminders delete 3                 # Delete item #3\n"
            printf "\treminders edit 2 \"New task name\"   # Edit item #2\n"
            printf "\treminders clear-completed \"Sams\"   # Clear completed items from Sams list\n"
        else
            printf "reminders\t${reminders_version}\n"
            printf "Terminal interface for macOS Reminders app\n\n"
            printf "USAGE:\n"
            printf "\treminders [COMMAND] [OPTIONS]\n"
            printf "COMMANDS:\n"
            printf "\tadd \"task\" [list]       Add a reminder to specified list (default: Reminders)\n"
            printf "\tdue \"task\" \"date\" [list] Add reminder with due date (YYYY-MM-DD or 'today'/'tomorrow')\n"
            printf "\tlist [list_name]        Show reminders from list (default: all incomplete)\n"
            printf "\tlists                   Show all reminder lists\n"
            printf "\tcomplete \"task\"         Mark a reminder as complete\n"
            printf "\tcomplete [number]       Mark numbered reminder as complete\n"
            printf "\tdelete \"task\"           Delete a reminder\n"
            printf "\tdelete [number]         Delete numbered reminder\n"
            printf "\tedit [number] \"new_text\" Edit numbered reminder\n"
            printf "\tsearch \"text\"           Search for reminders containing text\n"
            printf "\ttoday                   Show reminders due today or overdue\n"
            printf "\tclear-completed \"list\"  Clear all completed reminders from a list\n"
            printf "\t-h|--help               Show this help\n"
            printf "EXAMPLES:\n"
            printf "\treminders add \"Buy groceries\"\n"
            printf "\treminders add \"Review PR\" Work\n"
            printf "\treminders due \"Meeting with team\" tomorrow Work\n"
            printf "\treminders due \"Project deadline\" 2025-08-25\n"
            printf "\treminders list Work\n"
            printf "\treminders today\n"
            printf "\treminders delete 3                 # Delete item #3\n"
            printf "\treminders edit 2 \"New task name\"   # Edit item #2\n"
            printf "\treminders clear-completed \"Sams\"   # Clear completed items from Sams list\n"
        fi
    }

    create_simple_numbered_list() {
        osascript << 'EOF' > "$temp_reminders_file"
tell application "Reminders"
    set output to ""
    set allLists to lists
    repeat with aList in allLists
        set listName to name of aList
        set incompleteReminders to reminders of aList whose completed is false
        repeat with aReminder in incompleteReminders
            set reminderName to name of aReminder
            set reminderID to id of aReminder
            set output to output & (reminderID as string) & "|" & reminderName & "|" & listName & "\n"
        end repeat
    end repeat
    return output
end tell
EOF
    }

    add_reminder() {
        local task="$1"
        local list_name="${2:-Reminders}"
        
        if [[ -z "$task" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Task description required\n"
                bd_ansi reset
            else
                printf "✗ Task description required\n"
            fi
            return 1
        fi
        
        osascript << EOF
tell application "Reminders"
    set myList to list "$list_name"
    set newReminder to make new reminder at end of myList
    set name of newReminder to "$task"
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Added to '%s': %s\n" "$list_name" "$task"
                bd_ansi reset
            else
                printf "✓ Added to '%s': %s\n" "$list_name" "$task"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Failed to add reminder. Check if list '%s' exists.\n" "$list_name"
                bd_ansi reset
            else
                printf "✗ Failed to add reminder. Check if list '%s' exists.\n" "$list_name"
            fi
        fi
    }

    add_reminder_with_due_date() {
        local task="$1"
        local due_date="$2"
        local list_name="${3:-Reminders}"
        
        if [[ -z "$task" ]] || [[ -z "$due_date" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Task description and due date required\n"
                bd_ansi reset
            else
                printf "✗ Task description and due date required\n"
            fi
            return 1
        fi
        
        local applescript_date
        case "$due_date" in
            "today")
                applescript_date="current date"
                ;;
            "tomorrow")
                applescript_date="(current date) + (1 * days)"
                ;;
            [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
                local year=$(echo "$due_date" | cut -d'-' -f1)
                local month=$(echo "$due_date" | cut -d'-' -f2)
                local day=$(echo "$due_date" | cut -d'-' -f3)
                applescript_date="date \"$month/$day/$year\""
                ;;
            *)
                if type bd_ansi &>/dev/null; then
                    bd_ansi fg_red1
                    printf "✗ Invalid date format. Use YYYY-MM-DD, 'today', or 'tomorrow'\n"
                    bd_ansi reset
                else
                    printf "✗ Invalid date format. Use YYYY-MM-DD, 'today', or 'tomorrow'\n"
                fi
                return 1
                ;;
        esac
        
        osascript << EOF
tell application "Reminders"
    set myList to list "$list_name"
    set newReminder to make new reminder at end of myList
    set name of newReminder to "$task"
    set due date of newReminder to $applescript_date
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Added to '%s' (due %s): %s\n" "$list_name" "$due_date" "$task"
                bd_ansi reset
            else
                printf "✓ Added to '%s' (due %s): %s\n" "$list_name" "$due_date" "$task"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Failed to add reminder. Check if list '%s' exists.\n" "$list_name"
                bd_ansi reset
            else
                printf "✗ Failed to add reminder. Check if list '%s' exists.\n" "$list_name"
            fi
        fi
    }

    list_reminders() {
        local list_name="$1"
        
        if [[ -n "$list_name" ]]; then
            # Listing specific list - no need for numbered list
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_cyan1
                printf "📋 Reminders in '%s':\n" "$list_name"
                bd_ansi reset
            else
                printf "📋 Reminders in '%s':\n" "$list_name"
            fi
            
            osascript << EOF | grep -v "^$" | nl -nln -w3 -s'. '
tell application "Reminders"
    set myList to list "$list_name"
    set incompleteReminders to reminders of myList whose completed is false
    repeat with aReminder in incompleteReminders
        set reminderName to name of aReminder
        set reminderDue to due date of aReminder
        if reminderDue is not missing value then
            set dueDateStr to (month of reminderDue as integer) & "/" & (day of reminderDue) & "/" & (year of reminderDue)
            log "🔴 " & reminderName & " (due: " & dueDateStr & ")"
        else
            log "⚪ " & reminderName
        end if
    end repeat
end tell
EOF
        else
            # Listing all reminders - create numbered list
            create_simple_numbered_list
            
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_cyan1
                printf "📋 All incomplete reminders:\n"
                bd_ansi reset
            else
                printf "📋 All incomplete reminders:\n"
            fi
            
            if [[ -f "$temp_reminders_file" ]]; then
                local counter=1
                while IFS='|' read -r reminder_id reminder_name list_name; do
                    if [[ -n "$reminder_name" ]]; then
                        printf "  %2d. ⚪ %s (%s)\n" "$counter" "$reminder_name" "$list_name"
                        ((counter++))
                    fi
                done < "$temp_reminders_file"
            else
                printf "  No reminders available\n"
            fi
        fi
    }

    list_all_lists() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_cyan1
            printf "📁 Available reminder lists:\n"
            bd_ansi reset
        else
            printf "📁 Available reminder lists:\n"
        fi
        
        osascript << EOF | grep -v "^$"
tell application "Reminders"
    set allLists to lists
    repeat with aList in allLists
        set listName to name of aList
        set reminderCount to count of (reminders of aList whose completed is false)
        log "   " & listName & " (" & reminderCount & " items)"
    end repeat
end tell
EOF
    }

    complete_reminder() {
        local task="$1"
        
        if [[ "$task" =~ ^[0-9]+$ ]]; then
            complete_reminder_by_number "$task"
            return
        fi
        
        if [[ -z "$task" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Task description required\n"
                bd_ansi reset
            else
                printf "✗ Task description required\n"
            fi
            return 1
        fi
        
        osascript << EOF
tell application "Reminders"
    set allLists to lists
    set foundReminder to false
    repeat with aList in allLists
        set incompleteReminders to reminders of aList whose completed is false
        repeat with aReminder in incompleteReminders
            if name of aReminder contains "$task" then
                set completed of aReminder to true
                set completion date of aReminder to current date
                set foundReminder to true
                exit repeat
            end if
        end repeat
        if foundReminder then exit repeat
    end repeat
    if foundReminder then
        return "found"
    else
        return "not found"
    end if
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Completed: %s\n" "$task"
                bd_ansi reset
            else
                printf "✓ Completed: %s\n" "$task"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Reminder not found: %s\n" "$task"
                bd_ansi reset
            else
                printf "✗ Reminder not found: %s\n" "$task"
            fi
        fi
    }

    complete_reminder_by_number() {
        local number="$1"
        
        if [[ ! -f "$temp_reminders_file" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
                bd_ansi reset
            else
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
            fi
            return 1
        fi
        
        local line=$(sed -n "${number}p" "$temp_reminders_file")
        
        if [[ -z "$line" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Invalid number: %s\n" "$number"
                bd_ansi reset
            else
                printf "✗ Invalid number: %s\n" "$number"
            fi
            return 1
        fi
        
        local reminder_id=$(echo "$line" | cut -d'|' -f1)
        local reminder_name=$(echo "$line" | cut -d'|' -f2)
        
        osascript << EOF
tell application "Reminders"
    set targetReminder to reminder id "$reminder_id"
    set completed of targetReminder to true
    set completion date of targetReminder to current date
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Completed #%s: %s\n" "$number" "$reminder_name"
                bd_ansi reset
            else
                printf "✓ Completed #%s: %s\n" "$number" "$reminder_name"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Failed to complete reminder\n"
                bd_ansi reset
            else
                printf "✗ Failed to complete reminder\n"
            fi
        fi
    }

    delete_reminder() {
        local task="$1"
        
        if [[ "$task" =~ ^[0-9]+$ ]]; then
            delete_reminder_by_number "$task"
            return
        fi
        
        if [[ -z "$task" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Task description required\n"
                bd_ansi reset
            else
                printf "✗ Task description required\n"
            fi
            return 1
        fi
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_yellow1
            printf "🗑️  Searching for reminder: %s\n" "$task"
            bd_ansi reset
        else
            printf "🗑️  Searching for reminder: %s\n" "$task"
        fi
        
        osascript << EOF
tell application "Reminders"
    set allLists to lists
    set foundReminder to false
    repeat with aList in allLists
        set allReminders to reminders of aList
        repeat with aReminder in allReminders
            if name of aReminder contains "$task" then
                delete aReminder
                set foundReminder to true
                exit repeat
            end if
        end repeat
        if foundReminder then exit repeat
    end repeat
    if foundReminder then
        return "found"
    else
        return "not found"
    end if
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Deleted: %s\n" "$task"
                bd_ansi reset
            else
                printf "✓ Deleted: %s\n" "$task"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Reminder not found: %s\n" "$task"
                bd_ansi reset
            else
                printf "✗ Reminder not found: %s\n" "$task"
            fi
        fi
    }

    delete_reminder_by_number() {
        local number="$1"
        
        if [[ ! -f "$temp_reminders_file" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
                bd_ansi reset
            else
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
            fi
            return 1
        fi
        
        local line=$(sed -n "${number}p" "$temp_reminders_file")
        
        if [[ -z "$line" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Invalid number: %s\n" "$number"
                bd_ansi reset
            else
                printf "✗ Invalid number: %s\n" "$number"
            fi
            return 1
        fi
        
        local reminder_id=$(echo "$line" | cut -d'|' -f1)
        local reminder_name=$(echo "$line" | cut -d'|' -f2)
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_yellow1
            printf "🗑️  Deleting #%s: %s\n" "$number" "$reminder_name"
            bd_ansi reset
        else
            printf "🗑️  Deleting #%s: %s\n" "$number" "$reminder_name"
        fi
        
        osascript << EOF
tell application "Reminders"
    set targetReminder to reminder id "$reminder_id"
    delete targetReminder
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Deleted #%s: %s\n" "$number" "$reminder_name"
                bd_ansi reset
            else
                printf "✓ Deleted #%s: %s\n" "$number" "$reminder_name"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Failed to delete reminder\n"
                bd_ansi reset
            else
                printf "✗ Failed to delete reminder\n"
            fi
        fi
    }

    edit_reminder() {
        local number="$1"
        local new_text="$2"
        
        if [[ -z "$number" ]] || [[ -z "$new_text" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Number and new text required\n"
                bd_ansi reset
                printf "Usage: reminders edit [number] \"new text\"\n"
            else
                printf "✗ Number and new text required\n"
                printf "Usage: reminders edit [number] \"new text\"\n"
            fi
            return 1
        fi
        
        if [[ ! "$number" =~ ^[0-9]+$ ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ First argument must be a number\n"
                bd_ansi reset
            else
                printf "✗ First argument must be a number\n"
            fi
            return 1
        fi
        
        if [[ ! -f "$temp_reminders_file" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
                bd_ansi reset
            else
                printf "✗ No numbered list available. Run 'reminders list' first.\n"
            fi
            return 1
        fi
        
        local line=$(sed -n "${number}p" "$temp_reminders_file")
        
        if [[ -z "$line" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Invalid number: %s\n" "$number"
                bd_ansi reset
            else
                printf "✗ Invalid number: %s\n" "$number"
            fi
            return 1
        fi
        
        local reminder_id=$(echo "$line" | cut -d'|' -f1)
        local old_name=$(echo "$line" | cut -d'|' -f2)
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_yellow1
            printf "✏️  Editing #%s: %s → %s\n" "$number" "$old_name" "$new_text"
            bd_ansi reset
        else
            printf "✏️  Editing #%s: %s → %s\n" "$number" "$old_name" "$new_text"
        fi
        
        osascript << EOF
tell application "Reminders"
    set targetReminder to reminder id "$reminder_id"
    set name of targetReminder to "$new_text"
end tell
EOF
        
        if [[ $? -eq 0 ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_green1
                printf "✓ Updated #%s: %s\n" "$number" "$new_text"
                bd_ansi reset
            else
                printf "✓ Updated #%s: %s\n" "$number" "$new_text"
            fi
        else
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Failed to edit reminder\n"
                bd_ansi reset
            else
                printf "✗ Failed to edit reminder\n"
            fi
        fi
    }

    search_reminders() {
        local search_text="$1"
        
        if [[ -z "$search_text" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ Search text required\n"
                bd_ansi reset
            else
                printf "✗ Search text required\n"
            fi
            return 1
        fi
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_cyan1
            printf "🔍 Searching for: %s\n" "$search_text"
            bd_ansi reset
        else
            printf "🔍 Searching for: %s\n" "$search_text"
        fi
        
        osascript << EOF | grep -v "^$"
tell application "Reminders"
    set allLists to lists
    repeat with aList in allLists
        set listName to name of aList
        set allReminders to reminders of aList whose completed is false
        repeat with aReminder in allReminders
            set reminderName to name of aReminder
            if reminderName contains "$search_text" then
                set reminderDue to due date of aReminder
                if reminderDue is not missing value then
                    set dueDateStr to (month of reminderDue as integer) & "/" & (day of reminderDue) & "/" & (year of reminderDue)
                    log "   🔴 " & reminderName & " (" & listName & ", due: " & dueDateStr & ")"
                else
                    log "   ⚪ " & reminderName & " (" & listName & ")"
                end if
            end if
        end repeat
    end repeat
end tell
EOF
    }

    clear_completed() {
        local list_name="$1"
        
        if [[ -z "$list_name" ]]; then
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "✗ List name required\n"
                bd_ansi reset
                printf "Usage: reminders clear-completed \"list name\"\n"
            else
                printf "✗ List name required\n"
                printf "Usage: reminders clear-completed \"list name\"\n"
            fi
            return 1
        fi
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_yellow1
            printf "🗑️  Clearing completed reminders from '%s'...\n" "$list_name"
            bd_ansi reset
        else
            printf "🗑️  Clearing completed reminders from '%s'...\n" "$list_name"
        fi
        
        osascript << EOF
tell application "Reminders"
    set targetList to list "$list_name"
    set completedReminders to reminders of targetList whose completed is true
    set deletedCount to count of completedReminders
    
    repeat with aReminder in completedReminders
        delete aReminder
    end repeat
    
    return deletedCount
end tell
EOF
        
        local deleted_count=$?
        
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_green1
            printf "✓ Cleared completed reminders from '%s'\n" "$list_name"
            bd_ansi reset
        else
            printf "✓ Cleared completed reminders from '%s'\n" "$list_name"
        fi
    }
    
    show_today_reminders() {
        if type bd_ansi &>/dev/null; then
            bd_ansi fg_cyan1
            printf "📅 Reminders due today or overdue:\n"
            bd_ansi reset
        else
            printf "📅 Reminders due today or overdue:\n"
        fi
        
        osascript << 'EOF' | grep -v "^$"
tell application "Reminders"
    set todayDate to current date
    set todayEnd to todayDate - (time of todayDate) + (24 * 60 * 60) - 1
    
    set foundAny to false
    set allLists to lists
    repeat with aList in allLists
        set listName to name of aList
        -- Skip shopping lists that won't have due dates
        if listName is not in {"Groceries", "Sams"} then
            set incompleteReminders to reminders of aList whose completed is false
            
            repeat with aReminder in incompleteReminders
                try
                    set reminderDue to due date of aReminder
                    if reminderDue is not missing value then
                        -- Include anything due today or earlier (past due)
                        if reminderDue ≤ todayEnd then
                            if not foundAny then
                                set foundAny to true
                            end if
                            -- Check if overdue
                            if reminderDue < (todayDate - (time of todayDate)) then
                                log "  ⚠️  " & (name of aReminder) & " (" & listName & ") - OVERDUE"
                            else
                                log "  🔴 " & (name of aReminder) & " (" & listName & ")"
                            end if
                        end if
                    end if
                end try
            end repeat
        end if
    end repeat
    
    if not foundAny then
        log "  No reminders due today or overdue"
    end if
end tell
EOF
    }

    case "${1:-list}" in
        add)
            if [[ -n "$3" ]]; then
                add_reminder "$2" "$3"
            else
                add_reminder "$2"
            fi
            ;;
        due)
            if [[ -n "$4" ]]; then
                add_reminder_with_due_date "$2" "$3" "$4"
            else
                add_reminder_with_due_date "$2" "$3"
            fi
            ;;
        list|"")
            list_reminders "$2"
            ;;
        lists)
            list_all_lists
            ;;
        complete)
            complete_reminder "$2"
            ;;
        delete)
            delete_reminder "$2"
            ;;
        edit)
            edit_reminder "$2" "$3"
            ;;
        search)
            search_reminders "$2"
            ;;
        today)
            show_today_reminders
            ;;
        clear-completed)
            clear_completed "$2"
            ;;
        -h|--help|help)
            print_help
            ;;
        *)
            if type bd_ansi &>/dev/null; then
                bd_ansi fg_red1
                printf "Unknown command: %s\n\n" "$1"
                bd_ansi reset
            else
                printf "Unknown command: %s\n\n" "$1"
            fi
            print_help
            return 1
            ;;
    esac
}

