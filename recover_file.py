import json
import os

target_file = "/Users/kuldeepsharma/development/projects/KC/KC-Admin/lib/src/features/design/presentation/pages/design_form_page.dart"
log_path = "/Users/kuldeepsharma/.gemini/antigravity-ide/brain/ae69f74e-c994-4ad6-8e9f-44e44f1ac3a9/.system_generated/logs/transcript_full.jsonl"

try:
    with open(log_path, 'r') as f:
        for line in f:
            try:
                data = json.loads(line)
                if data.get('type') == 'PLANNER_RESPONSE':
                    tool_calls = data.get('tool_calls', [])
                    for call in tool_calls:
                        if call.get('name') == 'write_to_file':
                            args = call.get('args', {})
                            if target_file in args.get('TargetFile', ''):
                                print("Found write_to_file!")
                                with open('recovered.dart', 'w') as out:
                                    out.write(args.get('CodeContent', ''))
                                print("Saved to recovered.dart")
            except Exception as e:
                pass
except Exception as e:
    print(e)
