from hyperon import MeTTa

m = MeTTa()

# Load and run your MeTTa file
with open("medical_checker.metta") as f:
    code = f.read()

result = m.run(code)
print(result)