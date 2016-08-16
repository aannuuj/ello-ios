////
///  NotificationCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationCellSpec: QuickSpec {
    override func spec() {
        describe("NotificationCell") {
            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 320, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["authorId": author.id])
                subject.title = NotificationAttributedTitle.attributedTitle(.PostMentionNotification, author: author, subject: post)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 17
            }

            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 160, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["authorId": author.id])
                subject.title = NotificationAttributedTitle.attributedTitle(.PostMentionNotification, author: author, subject: post)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 51
            }

            context("snapshots") {
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["author": author])
                let title = NotificationAttributedTitle.attributedTitle(.PostMentionNotification, author: author, subject: post)
                let createdAt = NSDate(timeIntervalSinceNow: -86_400)
                let aspectRatio: CGFloat = 1
                let image = UIImage.imageWithColor(.blueColor(), size: CGSize(width: 300, height: 300))
                let message = "<p>This is a notification!</p>"

                let expectations: [(hasMessage: Bool, hasImage: Bool, canReply: Bool, buyButton: Bool)] = [
                    (hasMessage: true, hasImage: false, canReply: false, buyButton: false),
                    (hasMessage: true, hasImage: false, canReply: true, buyButton: false),
                    (hasMessage: false, hasImage: true, canReply: false, buyButton: false),
                    (hasMessage: false, hasImage: true, canReply: false, buyButton: true),
                    (hasMessage: false, hasImage: true, canReply: true, buyButton: false),
                    (hasMessage: false, hasImage: true, canReply: true, buyButton: true),
                    (hasMessage: true, hasImage: true, canReply: false, buyButton: false),
                    (hasMessage: true, hasImage: true, canReply: false, buyButton: true),
                    (hasMessage: true, hasImage: true, canReply: true, buyButton: false),
                    (hasMessage: true, hasImage: true, canReply: true, buyButton: true),
                ]
                for (hasMessage, hasImage, canReply, buyButton) in expectations {
                    it("notification\(hasMessage ? " with message" : "")\(hasImage ? " with image" : "")\(canReply ? " with reply button" : "")\(buyButton ? " with buy button" : "")") {
                        let subject = NotificationCell()
                        subject.title = title
                        subject.createdAt = createdAt
                        subject.user = author
                        subject.canReplyToComment = canReply
                        subject.canBackFollow = false
                        subject.post = post
                        subject.comment = nil
                        subject.aspectRatio = aspectRatio
                        subject.buyButtonVisible = buyButton
                        if hasImage {
                            subject.imageURL = NSURL(string: "http://ello.co/image.png")
                            subject.notificationImageView.image = image
                        }

                        if hasMessage {
                            waitUntil(timeout: 30) { done in
                                subject.onWebContentReady { _ in
                                    done()
                                }
                                subject.messageHtml = message
                            }
                        }
                        expectValidSnapshot(subject, device: .Phone6_Portrait)
                    }
                }
            }
        }
    }
}
