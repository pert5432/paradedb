CREATE INDEX idx_mock_items ON mock_items USING bm25 ((mock_items.*)) WITH (key_field='id', text_fields='{"description": {}, "category": {}}', numeric_fields='{"rating": {}}', boolean_fields='{"in_stock": {}}', json_fields='{"metadata": {}}');;;
CREATE INDEX ON mock_items USING hnsw (embedding vector_l2_ops);

-- Hybrid search with equal weights
SELECT
    description,
    category,
    rating,
    embedding,
    paradedb.weighted_mean(
        paradedb.minmax_bm25(id, 'idx_mock_items', 'description:keyboard'),
        1 - paradedb.minmax_norm(
          '[1,2,3]' <-> embedding, 
          MIN('[1,2,3]' <-> embedding) OVER (), 
          MAX('[1,2,3]' <-> embedding) OVER ()
        ),
        ARRAY[0.5,0.5]
    ) as score_hybrid
FROM mock_items
ORDER BY score_hybrid DESC
LIMIT 5;

-- All weighted on BM25
SELECT
    description,
    category,
    rating,
    embedding,
    paradedb.weighted_mean(
        paradedb.minmax_bm25(id, 'idx_mock_items', 'description:keyboard'),
        1 - paradedb.minmax_norm(
          '[1,2,3]' <-> embedding, 
          MIN('[1,2,3]' <-> embedding) OVER (), 
          MAX('[1,2,3]' <-> embedding) OVER ()
        ),
        ARRAY[1,0]
    ) as score_hybrid
FROM mock_items
ORDER BY score_hybrid DESC
LIMIT 5;

-- All weighted on HNSW
SELECT
    description,
    category,
    rating,
    embedding,
    paradedb.weighted_mean(
        paradedb.minmax_bm25(id, 'idx_mock_items', 'description:keyboard'),
        1 - paradedb.minmax_norm(
          '[1,2,3]' <-> embedding, 
          MIN('[1,2,3]' <-> embedding) OVER (), 
          MAX('[1,2,3]' <-> embedding) OVER ()
        ),
        ARRAY[0,1]
    ) as score_hybrid
FROM mock_items
ORDER BY score_hybrid DESC
LIMIT 5;
