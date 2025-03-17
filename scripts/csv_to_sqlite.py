import pandas as pd
import sqlite3
import os

# define data columns and corresponding sqlite data types (and set primary key column)
dict_sqlite_types = {"index": "INTEGER PRIMARY KEY", "Lemma": "TEXT", "URL": "TEXT", "Wortart": "TEXT", "Genus": "TEXT", "Artikel": "TEXT", "nur_im_Plural": "TEXT"} 

def get_sqlite_create_table_command(table_name: str):
    """
    Returns the SQL command to create a table in SQLite
    """
    return f"CREATE TABLE {table_name} (pk INTEGER PRIMARY KEY, Lemma TEXT, URL TEXT, Wortart TEXT, Genus TEXT, Artikel TEXT, nur_im_Plural TEXT)"

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

# Create a connection to a new SQLite database in dedida/assets folder
db_path = os.path.join(os.path.dirname(script_dir), "assets", "dedida.db")
if os.path.exists(db_path):
    raise FileExistsError("Database already exists")
    #os.remove(db_path)
conn = sqlite3.connect(db_path)
c = conn.cursor()

# create empty tables first
c.execute(get_sqlite_create_table_command("A1"))
c.execute(get_sqlite_create_table_command("A2"))
c.execute(get_sqlite_create_table_command("B1"))

# append the dataframes to the database tables
df_a1.to_sql("A1", conn, if_exists="append", dtype=dict_sqlite_types, index=True, index_label="pk")
df_a2.to_sql("A2", conn, if_exists="append", dtype=dict_sqlite_types, index=True, index_label="pk")
df_b1.to_sql("B1", conn, if_exists="append", dtype=dict_sqlite_types, index=True, index_label="pk")

# Commit the changes and close the connection
conn.commit()
conn.close()
