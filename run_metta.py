from hyperon import MeTTa

m = MeTTa()

# Load and run your MeTTa file
with open("test.metta") as f:
    code = f.read()

result = m.run(code)
print(result)