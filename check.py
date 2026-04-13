with open(r'e:\AVS\form_app_27_3_2026\lib\update_customer_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.read().split('\n')
for i, line in enumerate(lines):
    if '_photoFile' in line or '_profileImageBytes' in line or 'signatureFile' in line or 'signatureBytes' in line or '_form60File' in line or '_form60Bytes' in line:
        print(f"{i}: {line.strip()}")
