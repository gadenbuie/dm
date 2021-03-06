test_that("utils-methods work", {
  expect_equivalent_tbl(
    zoomed_dm() %>% arrange(d) %>% head(3) %>% get_zoomed_tbl(),
    head(tf_2() %>% arrange(d), 3)
  )

  # Not implemented for remote sources:
  skip_if_remote_src()
  expect_equivalent_tbl(
    zoomed_dm() %>% tail(2) %>% get_zoomed_tbl(),
    tail(tf_2(), 2)
  )
})
