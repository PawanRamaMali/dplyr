test_that("group_nest() works", {
  grouped <- group_by(starwars, species, homeworld)
  gdata <- group_data(grouped)

  res <- group_nest(starwars, species, homeworld)
  expect_type(pull(res), "list")
  expect_equal(
    attr(pull(res), "ptype"),
    vec_slice(select(starwars, -species, -homeworld), 0L)
  )

  expect_equal(res[1:2], structure(gdata[1:2], .drop = NULL))

  nested <- bind_rows(!!!res$data)
  expect_equal(
    names(nested),
    setdiff(names(starwars), c("species", "homeworld"))
  )
})

test_that("group_nest() can keep the grouping variables", {
  grouped <- group_by(starwars, species, homeworld)
  gdata <- group_data(grouped)

  res <- group_nest(starwars, species, homeworld, keep = TRUE)
  nested <- bind_rows(!!!res$data)
  expect_equal(names(nested), names(starwars))
})

test_that("group_nest() works on grouped data frames", {
  grouped <- group_by(starwars, species, homeworld)
  gdata <- group_data(grouped)

  res <- group_nest(grouped)
  expect_type(pull(res), "list")
  expect_equal(res[1:2], structure(gdata[1:2], .drop = NULL))
  expect_equal(
    names(bind_rows(!!!res$data)),
    setdiff(names(starwars), c("species", "homeworld"))
  )

  res <- group_nest(grouped, keep = TRUE)
  expect_type(pull(res), "list")
  expect_equal(attr(pull(res), "ptype"), vec_slice(starwars, 0L))

  expect_equal(res[1:2], structure(gdata[1:2], .drop = NULL))
  expect_equal(names(bind_rows(!!!res$data)), names(starwars))
})

test_that("group_nest.grouped_df() warns about ...", {
  expect_warning(group_nest(group_by(mtcars, cyl), cyl))
})

test_that("group_nest() works if no grouping column", {
  res <- group_nest(iris)
  expect_equal(res$data, list(iris))
  expect_equal(names(res), "data")
})

test_that("group_nest() respects .drop", {
  nested <- tibble(f = factor("b", levels = c("a", "b", "c")), x = 1, y = 2) %>%
    group_nest(f, .drop = TRUE)
  expect_equal(nrow(nested), 1L)
})
