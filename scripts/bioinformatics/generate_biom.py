import pandas as pd

taxonomy = pd.read_table('./data/input/curated_taxonomy_krona_format.txt', encoding='latin1', header=None)
taxonomy.rename(columns={0: 'Feature_ID'}, inplace=True)
taxonomy.set_index('Feature_ID', inplace=True)
taxonomy = taxonomy.drop(columns=['1'])

features = pd.read_table("./data/input/all_Leray_zotutab_4.txt")
features = features.rename(columns= {"#OTU ID": "Feature_ID"})

merged_data = pd.merge(taxonomy, features, on='Feature_ID')
merged_data.set_index('Feature_ID', inplace=True)

merged_data.to_csv("./data/input/new_feature_table.tsv", sep='\t', index = True)