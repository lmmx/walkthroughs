# "Exploring handwritten digit classification: a tidy analysis of the MNIST dataset"
# via http://varianceexplained.org/r/digit-eda/

# library(ggplot2)
# library(scales)
# theme_set(theme_light())
# 
# set.seed(2018)
# 
# g <- pixels_gathered %>%
#   group_by(label) %>%
#   filter(instance %in% sample(unique(instance), 10)) %>%
#   mutate(instance = rank(instance)) %>%
#   ungroup() %>%
#   ggplot(aes(x, y, fill = value)) +
#   geom_tile(show.legend = FALSE) +
#   facet_grid(instance ~ label) +
#   scale_fill_gradient2(low = "white", high = "black", mid = "gray", midpoint = 127.5) +
#   theme_void() +
#   theme(strip.text = element_blank())
# 
# ggsave(g, file = "images/mnist.png", height = 5, width = 5, dpi = 72)

library(readr)
library(dplyr)

mnist_raw <- read_csv("https://pjreddie.com/media/files/mnist_train.csv", col_names = FALSE)

mnist_raw[1:10, 1:10]

library(tidyr)

pixels_gathered <- mnist_raw %>%
  head(10000) %>%
  rename(label = X1) %>%
  mutate(instance = row_number()) %>%
  gather(pixel, value, -label, -instance) %>%
  tidyr::extract(pixel, "pixel", "(\\d+)", convert = TRUE) %>%
  mutate(pixel = pixel - 2,
  x = pixel %% 28,
  y = 28 - pixel %/% 28)

pixels_gathered

library(ggplot2)
theme_set(theme_light())

pixels_gathered %>%
  filter(instance <= 12) %>%
  ggplot(aes(x, y, fill = value)) +
  geom_tile() +
  facet_wrap(~ instance + label)

ggplot(pixels_gathered, aes(value)) +
  geom_histogram()

pixel_summary <- pixels_gathered %>%
  group_by(x, y, label) %>%
  summarize(mean_value = mean(value)) %>%
  ungroup()

pixel_summary

pixel_summary %>%
  ggplot(aes(x, y, fill = mean_value)) +
  geom_tile() +
  scale_fill_gradient2(low = "white", high = "black", mid = "gray", midpoint = 127.5) +
  facet_wrap(~ label, nrow = 2) +
  labs(title = "Average value of each pixel in 10 MNIST digits",
       fill = "Average value") +
  theme_void()

pixels_joined <- pixels_gathered %>%
  inner_join(pixel_summary, by = c("label", "x", "y"))

image_distances <- pixels_joined %>%
  group_by(label, instance) %>%
  summarize(euclidean_distance = sqrt(mean((value - mean_value) ^ 2)))
  
image_distances

ggplot(image_distances, aes(factor(label), euclidean_distance)) +
  geom_boxplot() +
  labs(x = "Digit",
  y = "Euclidean distance to the digit centroid")

worst_instances <- image_distances %>%
  top_n(6, euclidean_distance) %>%
  mutate(number = rank(-euclidean_distance))

pixels_gathered %>%
  inner_join(worst_instances, by = c("label", "instance")) %>%
  ggplot(aes(x, y, fill = value)) +
  geom_tile(show.legend = FALSE) +
  scale_fill_gradient2(low = "white", high = "black", mid = "gray", midpoint = 127.5) +
  facet_grid(label ~ number) +
  labs(title = "Least typical digits",
       subtitle = "The 6 digits within each label that had the greatest distance to the centroid") +
  theme_void() +
  theme(strip.text = element_blank())

digit_differences <- crossing(compare1 = 0:9, compare2 = 0:9) %>%
  filter(compare1 != compare2) %>%
  mutate(negative = compare1, positive = compare2) %>%
  gather(class, label, positive, negative) %>%
  inner_join(pixel_summary, by = "label") %>%
  select(-label) %>%
  spread(class, mean_value)

ggplot(digit_differences, aes(x, y, fill = positive - negative)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = .5) +
  facet_grid(compare2 ~ compare1) +
  theme_void() +
  labs(title = "Pixels that distinguish pairs of MNIST images",
       subtitle = "Red means the pixel is darker for that row's digit, and blue means the pixel is darker for that column's digit.")
