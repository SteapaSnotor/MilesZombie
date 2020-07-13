extends Node

"""
	Must work together with the debug singleton. Receive player inputs
	draws the UI for debugging features.
"""

signal fill_grid
signal print_text
signal help
signal show_index_all
signal show_pos_all
signal show_overlapping

onready var input = $CanvasLayer/MainConsole/Input/InputText
onready var output = $CanvasLayer/MainConsole/Output/OutputText

var commands = {
	'fill_grid':[true],
	'print_text':[''],
	'help':[],
	'show_index_all':[],
	'show_pos_all':[],
	'show_overlapping':[]
}

#initialize console
func init(version):
	#console only commands
	connect('help',self,'help')
	connect('print_text',self,'print_text')
	
	#welcome screen
	var date = OS.get_date()
	var day = str(date['day'])
	var month = str(date['month'])
	var year = str(date['year'])
	#MM/DD/YYYY ffs america
	var text = 'Debug Console v' + str(version) + '. ' + month + '/' + day + '/' + year
	text = text + '. Copyright Steapa Snotor 2020.' 
	print_text(text)
	
func execute_command(command,args=[]):
	if commands.keys().find(command) == -1 :
		print_text('Invalid Command')
	elif commands[command].size() != args.size():
		print_text('Invalid number of arguments.')
	else:
		if args != [] and args.size()>1:
			emit_signal(command,args)
		elif args != [] and args.size() == 1:
			emit_signal(command,args[0])
		else:
			emit_signal(command)
	
func print_text(text):
	if output.get_line_count() >= 9:
		output.set_text('')
	
	output.set_text(output.get_text() +'\n' + text + '\n')

func help():
	for command in commands.keys():
		print_text(str(command))

func on_input_command(event):
	#TODO: Convert values from arguments to real types.
	if event.is_action_pressed('console_enter'):
		#try extract commands and arguments
		var input_text = input.get_text()
		var command = ''
		var args = []
		var index = 0
		
		for ch in input_text:
			if ch != '<':
				command = command.insert(command.length()+1,ch)
			else:
				#arguments
				var is_arg = false
				var new_arg = ''
				for arg_ch in input_text:
					if is_arg and arg_ch != ',' and arg_ch != '>':
						new_arg = new_arg.insert(new_arg.length()+1,arg_ch)
					elif is_arg and arg_ch == ',':
						args.append(new_arg)
						new_arg = ''
					elif is_arg and arg_ch == '>':
						args.append(new_arg)
						new_arg = ''
						is_arg = false
					
					if arg_ch == '<' and not is_arg:
						is_arg = true
				break
		print_text('>'+ input_text)
		input.set_text('')
		execute_command(command,args)
		#print(command)
		#print(args)








