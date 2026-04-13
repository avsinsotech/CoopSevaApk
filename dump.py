with open('e:/AVS/form_app_27_3_2026/lib/new_customer_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.read().split('\n')

in_sig = False
for line in lines:
    if 'Widget _buildSignature' in line:
        in_sig = True
    if in_sig:
        print(line.strip())
        if 'Widget _build' in line and 'Signature' not in line: break

in_ovd = False
for line in lines:
    if 'Widget _buildOvdUpload' in line:
        in_ovd = True
    if in_ovd:
        print(line.strip())
        if 'Widget _build' in line and 'OvdUpload' not in line: break
