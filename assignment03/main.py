import pandas as pd

sid = 12
df = pd.read_csv("projects.csv")
projects = df[sid-1::50]['project_name'].values.tolist()
print(projects)
