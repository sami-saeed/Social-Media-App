import consumer from "channels/consumer"

document.addEventListener("DOMContentLoaded", () => {
  const postShow = document.querySelector("[data-post-id]")
  if (!postShow) return

  const postId = postShow.dataset.postId

  consumer.subscriptions.create(
    { channel: "LinkScraperChannel", post_id: postId },
    {
      received(data) {
        if (data.title) {
          document.querySelector("h1").innerHTML =
            `<a href="/posts/${postId}" class="text-decoration-none text-dark">${data.title}</a>`
        }

        if (data.image_url) {
          const imgTag = `<img src="${data.image_url}" alt="Post Image" class="img-fluid w-100 mb-3" style="object-fit: cover;">`
          const imgContainer = document.querySelector(".mb-5")
          imgContainer.querySelector("img")?.remove()
          imgContainer.insertAdjacentHTML("afterbegin", imgTag)
        }

        if (data.content) {
          document.querySelector(".mb-5").innerHTML = data.content
        }
      }
    }
  )
})
