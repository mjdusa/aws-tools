# scan_for_sc_parent_stack.py

Usage: python scan_for_sc_parent_stack.py [regions]

This will use the current boto/awscli credentials of your shell.
If you want to use a specific profile you can prefix the command with `AWS_PROFILE=myprofilename` 
 or export the AWS_PROFILE env var.
You will need boto3 installed in the virtual environment you run this in.


```
python3 -m venv venv
source venv/bin/activate
pip install boto3
python scan_for_sc_parent_stack.py
```

When you're done:
```
deactivate
rm -rf venv
```