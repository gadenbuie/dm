# basic tests -------------------------------------------------------------


test_that("basic test: 'group_by()'-methods work", {
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% get_zoomed_tbl(),
    group_by(tf_2(), e)
  )

  expect_dm_error(
    group_by(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'select()'-methods work", {
  expect_equivalent_tbl(
    select(zoomed_dm(), e, a = c) %>% get_zoomed_tbl(),
    select(tf_2(), e, a = c)
  )

  expect_dm_error(
    select(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'rename()'-methods work", {
  expect_equivalent_tbl(
    rename(zoomed_dm(), a = c) %>% get_zoomed_tbl(),
    rename(tf_2(), a = c)
  )

  expect_dm_error(
    rename(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'mutate()'-methods work", {
  expect_equivalent_tbl(
    mutate(zoomed_dm(), d_2 = d * 2) %>% get_zoomed_tbl(),
    mutate(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    mutate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})


test_that("basic test: 'transmute()'-methods work", {
  expect_equivalent_tbl(
    transmute(zoomed_dm(), d_2 = d * 2) %>% get_zoomed_tbl(),
    transmute(tf_2(), d_2 = d * 2)
  )

  expect_dm_error(
    transmute(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'ungroup()'-methods work", {
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% ungroup() %>% get_zoomed_tbl(),
    group_by(tf_2(), e) %>% ungroup()
  )

  expect_dm_error(
    ungroup(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'summarise()'-methods work", {
  expect_equivalent_tbl(
    summarise(zoomed_dm(), d_2 = mean(d, na.rm = TRUE)) %>% get_zoomed_tbl(),
    summarise(tf_2(), d_2 = mean(d, na.rm = TRUE))
  )

  expect_dm_error(
    summarise(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'filter()'-methods work", {
  skip_if_src("maria")

  expect_equivalent_tbl(
    zoomed_dm() %>%
      filter(d > mean(d, na.rm = TRUE)) %>%
      dm_update_zoomed() %>%
      tbl("tf_2"),
    tf_2() %>%
      filter(d > mean(d, na.rm = TRUE))
  )
})

test_that("basic test: 'filter()'-methods work (2)", {
  expect_dm_error(
    filter(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'distinct()'-methods work", {
  expect_equivalent_tbl(
    distinct(zoomed_dm(), d_new = d) %>% dm_update_zoomed() %>% tbl("tf_2"),
    distinct(tf_2(), d_new = d)
  )

  expect_dm_error(
    distinct(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'arrange()'-methods work", {
  # standard arrange
  expect_equivalent_tbl(
    arrange(zoomed_dm(), e) %>% get_zoomed_tbl(),
    arrange(tf_2(), e)
  )

  # arrange within groups
  expect_equivalent_tbl(
    group_by(zoomed_dm(), e) %>% arrange(desc(d), .by_group = TRUE) %>% get_zoomed_tbl(),
    arrange(group_by(tf_2(), e), desc(d), .by_group = TRUE)
  )

  expect_dm_error(
    arrange(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'slice()'-methods work", {
  skip_if_remote_src()
  expect_message(
    expect_equivalent_tbl(slice(zoomed_dm(), 3:6) %>% get_zoomed_tbl(), slice(tf_2(), 3:6)),
    "`slice.zoomed_dm\\(\\)` can potentially"
  )

  # silent when no PK available
  expect_silent(
    expect_equivalent_tbl(
      slice(dm_zoom_to(dm_for_disambiguate(), iris_3), 1:3) %>% get_zoomed_tbl(),
      slice(iris_3(), 1:3)
    )
  )

  # silent when no PK available anymore
  expect_silent(
    mutate(zoomed_dm(), c = 1) %>% slice(1:3)
  )

  expect_silent(
    expect_equivalent_tbl(
      slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% get_zoomed_tbl(),
      slice(tf_2(), if_else(d < 5, 1:6, 7:2))
    )
  )

  expect_dm_error(
    slice(dm_for_filter(), 2),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work", {
  expect_equivalent_tbl(
    left_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    left_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    inner_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    inner_join(tf_2(), tf_1(), by = c("d" = "a"))
  )


  expect_equivalent_tbl(
    semi_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    semi_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    anti_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    anti_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  # SQLite doesn't implement right join
  skip_if_src("sqlite")
  skip_if_src("maria")
  expect_equivalent_tbl(
    full_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    full_join(tf_2(), tf_1(), by = c("d" = "a"))
  )

  expect_equivalent_tbl(
    right_join(zoomed_dm(), tf_1) %>% dm_update_zoomed() %>% tbl("tf_2"),
    right_join(tf_2(), tf_1(), by = c("d" = "a"))
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (2)", {
  # fails if RHS not linked to zoomed table and no by is given
  expect_dm_error(
    left_join(zoomed_dm(), tf_4),
    "tables_not_neighbours"
  )

  # works, if by is given
  expect_equivalent_tbl(
    left_join(zoomed_dm(), tf_4, by = c("e" = "j")) %>% dm_update_zoomed() %>% tbl("tf_2"),
    left_join(tf_2(), tf_4(), by = c("e" = "j"))
  )

  # explicitly select columns from RHS using argument `select`
  expect_equivalent_tbl(
    left_join(zoomed_dm_2(), tf_2, select = c(starts_with("c"), e)) %>% dm_update_zoomed() %>% tbl("tf_3"),
    left_join(tf_3(), select(tf_2(), c, e), by = c("f" = "e"))
  )

  # explicitly select and rename columns from RHS using argument `select`
  expect_equivalent_tbl(
    left_join(zoomed_dm_2(), tf_2, select = c(starts_with("c"), d_new = d, e)) %>% dm_update_zoomed() %>% tbl("tf_3"),
    left_join(tf_3(), select(tf_2(), c, d_new = d, e), by = c("f" = "e"))
  )

  # a former FK-relation could not be tracked
  expect_dm_error(
    zoomed_dm() %>% mutate(e = e) %>% left_join(tf_3),
    "fk_not_tracked"
  )

  # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
  expect_identical(
    left_join(zoomed_dm(), tf_3, select = c(d = g, f)) %>% dm_update_zoomed() %>% dm_get_fk(tf_2, tf_1),
    new_keys("tf_2.d")
  )

  # keys are correctly tracked if selected columns from 'y' have same name as key columns from 'x'
  expect_identical(
    semi_join(zoomed_dm(), tf_3, select = c(d = g, f)) %>% dm_update_zoomed() %>% dm_get_fk(tf_2, tf_1),
    new_keys("d")
  )

  skip_if_src("maria")
  # multi-column "by" argument
  expect_equivalent_tbl(
    dm_zoom_to(dm_for_disambiguate(), iris_2) %>% left_join(iris_2, by = c("key", "Sepal.Width", "other_col")) %>% get_zoomed_tbl(),
    left_join(
      iris_2() %>% rename_at(vars(matches("^[PS]")), ~ paste0("iris_2.x.", .)) %>% rename(Sepal.Width = iris_2.x.Sepal.Width),
      iris_2() %>% rename_at(vars(matches("^[PS]")), ~ paste0("iris_2.y.", .)),
      by = c("key", "Sepal.Width" = "iris_2.y.Sepal.Width", "other_col")
    )
  )
})

test_that("basic test: 'join()'-methods for `zoomed.dm` work (2)", {
  # auto-added RHS-by argument
  expect_message(
    dm_zoom_to(dm_for_disambiguate(), iris_2) %>%
      left_join(iris_2, by = c("key", "Sepal.Width", "other_col"), select = -key) %>%
      get_zoomed_tbl(),
    "Using `select = c(-key, key)`.",
    fixed = TRUE
  )

  skip_if_src("sqlite")
  # test RHS-by name collision
  expect_equivalent_dm(
    dm_for_filter() %>%
      dm_rename(tf_2, "...1" = d) %>%
      dm_zoom_to(tf_3) %>%
      right_join(tf_2) %>%
      dm_update_zoomed(),
    dm_for_filter() %>%
      dm_zoom_to(tf_3) %>%
      right_join(tf_2) %>%
      dm_update_zoomed() %>%
      dm_rename(tf_3, "...1" = d) %>%
      dm_rename(tf_2, "...1" = d)
  )
})

test_that("basic test: 'join()'-methods for `dm` throws error", {
  expect_dm_error(
    left_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    inner_join(dm_for_filter()),
    "only_possible_w_zoom"
  )


  expect_dm_error(
    semi_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    anti_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    full_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    right_join(dm_for_filter()),
    "only_possible_w_zoom"
  )

  expect_dm_error(
    inner_join(dm_zoom_to(dm_for_filter(), tf_1), tf_7),
    "table_not_in_dm"
  )

  skip("No nest_join() for now")
  expect_dm_error(
    nest_join(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

# test key tracking for all methods ---------------------------------------

# dm_for_filter(), zoomed to tf_2; PK: c; 2 outgoing FKs: d, e; no incoming FKS
zoomed_grouped_out_dm <- dm_zoom_to(dm_for_filter(), tf_2) %>% group_by(c, e)

# dm_for_filter(), zoomed to tf_3; PK: f; 2 incoming FKs: tf_4$j, tf_2$e; no outgoing FKS:
zoomed_grouped_in_dm <- dm_zoom_to(dm_for_filter(), tf_3) %>% group_by(g)

test_that("key tracking works", {

  # rename()

  expect_identical(
    zoomed_grouped_out_dm %>% rename(c_new = c) %>% dm_update_zoomed() %>% dm_get_pk(tf_2),
    new_keys("c_new")
  )

  expect_identical(
    zoomed_grouped_out_dm %>%
      rename(e_new = e) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl() %>%
      filter(child_table == "tf_2", parent_table == "tf_3") %>%
      pull(child_fk_cols),
    "e_new"
  )

  expect_identical(
    # FKs should not be dropped when renaming the PK they are pointing to; tibble from `dm_get_all_fks()` shouldn't change
    zoomed_grouped_in_dm %>%
      rename(f_new = f) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_filter() %>%
      dm_get_all_fks_impl()
  )

  # summarize()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      summarize(g_list = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  # transmute()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      transmute(d_mean = mean(d)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that no keys remain
    zoomed_grouped_in_dm %>%
      transmute(g_list = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  # mutate()

  expect_identical(
    # grouped by two key cols: "c" and "e" -> these two remain
    zoomed_grouped_out_dm %>%
      mutate(d_mean = mean(d), d = d * 2) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(c("c", "e"))
  )

  expect_identical(
    # grouped_by non-key col means, that only key-columns that are not touched remain for mutate()
    zoomed_grouped_in_dm %>%
      mutate(f = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names(character())
  )

  expect_identical(
    # grouped_by non-key col means, that only key-columns that are not touched remain for
    zoomed_grouped_in_dm %>%
      mutate(g_new = list(g)) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names("f")
  )

  # chain of renames & other transformations

  expect_identical(
    zoomed_grouped_out_dm %>%
      summarize(d_mean = mean(d)) %>%
      ungroup() %>%
      rename(e_new = e) %>%
      group_by(e_new) %>%
      transmute(c = paste0(c, "_animal")) %>%
      dm_insert_zoomed("new_tbl") %>%
      get_all_keys("new_tbl"),
    set_names("e_new")
  )

  # FKs that point to a PK that vanished, should also vanish
  pk_gone_dm <- zoomed_grouped_in_dm %>%
    select(g_new = g) %>%
    dm_update_zoomed()

  expect_identical(
    pk_gone_dm %>%
      dm_get_fk(tf_2, tf_3),
    new_keys(character())
  )

  expect_identical(
    pk_gone_dm %>%
      dm_get_fk(tf_4, tf_3),
    new_keys(character())
  )

  expect_identical(
    distinct(zoomed_dm(), d_new = d) %>% dm_update_zoomed() %>% dm_get_all_fks_impl(),
    dm_get_all_fks_impl(dm_for_filter()) %>%
      filter(child_fk_cols != "e") %>%
      mutate(child_fk_cols = if_else(child_fk_cols == "d", "d_new", child_fk_cols))
  )

  expect_identical(
    arrange(zoomed_dm(), e) %>% dm_update_zoomed() %>% dm_get_all_fks_impl(),
    dm_get_all_fks_impl(dm_for_filter())
  )

  expect_identical(
    dm_for_flatten() %>%
      dm_zoom_to(fact) %>%
      select(dim_1_key, dim_3_key, dim_2_key) %>%
      dm_update_zoomed() %>%
      dm_get_all_fks_impl(),
    dm_for_flatten() %>%
      dm_get_all_fks_impl() %>%
      filter(child_fk_cols != "dim_4_key")
  )


  # it should be possible to combine 'filter' on a zoomed_dm with all other dplyr-methods; example: 'rename'
  expect_equivalent_dm(
    dm_zoom_to(dm_for_filter(), tf_2) %>%
      filter(d < 6) %>%
      rename(c_new = c, d_new = d) %>%
      dm_update_zoomed(),
    dm_filter(dm_for_filter(), tf_2, d < 6) %>%
      dm_rename(tf_2, c_new = c, d_new = d)
  )

  # slice() and dm_nycflights_13() (with FK constraints) do not work on DB
  skip_if_remote_src()

  # keys tracking when there are no keys to track
  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% mutate(time_hour_fmt = format(time_hour, tz = "UTC"))
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      summarize(avg_wind_speed = mean(wind_speed)) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% summarize(avg_wind_speed = mean(wind_speed))
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      transmute(celsius_temp = (temp - 32) * 5 / 9) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% transmute(celsius_temp = (temp - 32) * 5 / 9)
  )

  # keys tracking when there are no keys to track
  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% mutate(time_hour_fmt = format(time_hour, tz = "UTC"))
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      summarize(avg_wind_speed = mean(wind_speed)) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% summarize(avg_wind_speed = mean(wind_speed))
  )

  expect_equivalent_tbl(
    dm_zoom_to(dm_nycflights_small(), weather) %>%
      transmute(celsius_temp = (temp - 32) * 5 / 9) %>%
      get_zoomed_tbl(),
    tbl(dm_nycflights_small(), "weather") %>% transmute(celsius_temp = (temp - 32) * 5 / 9)
  )

  expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = FALSE) %>% get_tracked_cols(), set_names(c("d", "e")))
  expect_message(
    expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2)) %>% get_tracked_cols(), set_names(c("c", "d", "e"))),
    "Keeping PK"
  )
  expect_identical(slice(zoomed_dm(), if_else(d < 5, 1:6, 7:2), .keep_pk = TRUE) %>% get_tracked_cols(), set_names(c("c", "d", "e")))
})


test_that("can use column as primary and foreign key", {
  f <- tibble(data_card_1 = 1:3)
  data_card_1 <- tibble(data_card_1 = 1:3)

  dm <-
    dm(f, data_card_1) %>%
    dm_add_pk(f, data_card_1) %>%
    dm_add_pk(data_card_1, data_card_1) %>%
    dm_add_fk(f, data_card_1, data_card_1)

  expect_equivalent_dm(
    dm %>%
      dm_zoom_to(f) %>%
      dm_update_zoomed(),
    dm
  )
})

test_that("'summarize_at()' etc. work", {
  skip_if_remote_src()
  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      summarize_at(vars(lat, lon), list(mean = mean, min = min, max = max)) %>%
      get_zoomed_tbl(),
    pull_tbl(dm_nycflights_small(), airports) %>%
      summarize_at(vars(lat, lon), list(mean = mean, min = min, max = max))
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      select(3:6) %>%
      summarize_all(list(mean = mean, median = median)) %>%
      get_zoomed_tbl(),
    pull_tbl(dm_nycflights_small(), airports) %>%
      select(3:6) %>%
      summarize_all(list(mean = mean, median = median))
  )

  expect_equivalent_tbl(
    dm_nycflights_small() %>%
      dm_zoom_to(airports) %>%
      summarize_if(is_double, list(mean = mean, median = median)) %>%
      get_zoomed_tbl(),
    pull_tbl(dm_nycflights_small(), airports) %>%
      summarize_if(is_double, list(mean = mean, median = median))
  )
})

test_that("unique_prefix()", {
  expect_equal(unique_prefix(character()), "...")
  expect_equal(unique_prefix(c("a", "bc", "ef")), "...")
  expect_equal(unique_prefix(c("a", "bcd", "ef")), "...")
  expect_equal(unique_prefix(c("a", "....", "ef")), "....")
})
