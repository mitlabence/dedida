import pandas as pd
import sqlite3
import os

# define data columns and corresponding sqlite data types (and set primary key column)
dict_sqlite_types = {"index": "INTEGER PRIMARY KEY", "level": "TEXT", "Lemma": "TEXT", "URL": "TEXT", "Wortart": "TEXT", "Genus": "TEXT", "Artikel": "TEXT", "nur_im_Plural": "TEXT"} 

def get_sqlite_create_table_command(table_name: str):
    """
    Returns the SQL command to create a table in SQLite
    """
    return f"CREATE TABLE {table_name} (pk INTEGER PRIMARY KEY, level TEXT, Lemma TEXT, URL TEXT, Wortart TEXT, Genus TEXT, Artikel TEXT, nur_im_Plural TEXT)"

# assuming the script is in dedida/scripts/, move to dedida/data
script_dir = os.path.dirname(__file__)
data_folder = os.path.join(os.path.dirname(script_dir), "data")
print("Data Folder Path:", data_folder)
fpath_dataset_a1 = os.path.join(data_folder, "A1.csv")
fpath_dataset_a2 = os.path.join(data_folder, "A2.csv")
fpath_dataset_b1 = os.path.join(data_folder, "B1.csv")

# Read the CSV files
df_a1 = pd.read_csv(fpath_dataset_a1)
df_a2 = pd.read_csv(fpath_dataset_a2)
df_b1 = pd.read_csv(fpath_dataset_b1)
# add level
df_a1["level"] = "A1"
df_a2["level"] = "A2"
df_b1["level"] = "B1"

# assert columns for all dataframes match, then concatenate them
assert df_a1.columns.tolist() == df_a2.columns.tolist() == df_b1.columns.tolist()
df = pd.concat([df_a1, df_a2, df_b1], ignore_index=True)

# Create a connection to a new SQLite database in dedida/assets folder
db_path = os.path.join(os.path.dirname(script_dir), "assets", "dedida.db")
if os.path.exists(db_path):
    raise FileExistsError("Database already exists")
    #os.remove(db_path)
conn = sqlite3.connect(db_path)
c = conn.cursor()

# create empty tables first
c.execute(get_sqlite_create_table_command("vocabulary"))

# append the dataframes to the (empty) database tables
df.to_sql("vocabulary", conn, if_exists="append", dtype=dict_sqlite_types, index=True, index_label="pk")

# Commit the changes and close the connection
conn.commit()
conn.close()
