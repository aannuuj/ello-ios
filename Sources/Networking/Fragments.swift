////
///  Fragments.swift
//

struct Fragments: Equatable {
    //|
    //|  FRAGMENTS
    //|
    static let categoryPostActions = Fragments(
        """
        fragment categoryPostActions on CategoryPostActions {
            feature { href label method }
            unfeature { href label method }
        }
        """
    )

    static let imageProps = Fragments(
        """
        fragment imageProps on Image {
          url
          metadata { height width type size }
        }
        """
    )

    static let tshirtProps = Fragments(
        """
        fragment tshirtProps on TshirtImageVersions {
          regular { ...imageProps }
          large { ...imageProps }
          original { ...imageProps }
        }
        """,
        needs: [imageProps]
    )

    static let responsiveProps = Fragments(
        """
        fragment responsiveProps on ResponsiveImageVersions {
          mdpi { ...imageProps }
          hdpi { ...imageProps }
          xhdpi { ...imageProps }
          optimized { ...imageProps }
        }
        """,
        needs: [imageProps]
    )

    static let authorProps = Fragments(
        """
        fragment authorProps on User {
          id
          username
          name
          currentUserState { relationshipPriority }
          settings {
            hasCommentingEnabled hasLovesEnabled hasRepostingEnabled hasSharingEnabled
            isCollaborateable isHireable
          }
          avatar {
            ...tshirtProps
          }
          coverImage {
            ...responsiveProps
          }
        }
        """,
        needs: [tshirtProps, responsiveProps]
    )

    static let categoryProps = Fragments(
        """
        fragment categoryProps on Category {
          id name slug order allowInOnboarding isCreatorType level description
          tileImage { ...tshirtProps }
        }
        """,
        needs: [tshirtProps]
    )

    static let pageHeaderUserProps = Fragments(
        """
        fragment pageHeaderUserProps on User {
          id
          username
          name
          avatar {
            ...tshirtProps
          }
          coverImage {
            ...responsiveProps
          }
        }
        """,
        needs: [tshirtProps, responsiveProps]
    )

    static let assetProps = Fragments(
        """
        fragment assetProps on Asset {
          id
          attachment { ...responsiveProps }
        }
        """
    )
    static let contentProps = Fragments(
        """
        fragment contentProps on ContentBlocks {
          linkUrl
          kind
          data
          links { assets }
        }
        """
    )
    static let postSummary = Fragments(
        """
        fragment postSummary on Post {
          id
          token
          createdAt
          summary { ...contentProps }
          author { ...authorProps }
          artistInviteSubmission { id artistInvite { id } }
          assets { ...assetProps }
          postStats { lovesCount commentsCount viewsCount repostsCount }
          currentUserState { watching loved reposted }
        }
        """,
        needs: [contentProps, assetProps, imageProps, tshirtProps, responsiveProps, authorProps]
    )

    static let postDetails = Fragments(
        """
        fragment postDetails on Post {
            ...postSummary
            content { ...contentProps }
            repostContent { ...contentProps }
            categoryPosts {
                id actions { ...categoryPostActions } status
                category { ...categoryProps }
                featuredAt submittedAt removedAt unfeaturedAt
                featuredBy { id username name } submittedBy { id username name }
            }
            repostedSource {
                ...postSummary
            }
        }
        """,
        needs: [contentProps, postSummary, categoryPostActions, categoryProps]
    )
    static let loveDetails = Fragments(
        """
        fragment loveDetails on Love {
            id
            post { ...postDetails }
            user { id }
        }
        """,
        needs: [postDetails]
    )
    static let commentDetails = Fragments(
        """
        fragment commentDetails on Comment {
            id
            createdAt
            parentPost { id }
            assets { ...assetProps }
            author { ...authorProps }
            content { ...contentProps }
            summary { ...contentProps }
        }
        """,
        needs: [authorProps, contentProps, assetProps]
    )

    static let userDetails = Fragments(
        """
        fragment userDetails on User {
          id
          username
          name
          formattedShortBio
          location
          badges
          externalLinksList { url text icon }
          # isCommunity
          userStats { totalViewsCount postsCount lovesCount followersCount followingCount }
          currentUserState { relationshipPriority }
          settings {
            hasCommentingEnabled hasLovesEnabled hasRepostingEnabled hasSharingEnabled
            isCollaborateable isHireable
          }
          avatar {
            ...tshirtProps
          }
          coverImage {
            ...responsiveProps
          }
          categoryUsers(roles: [CURATOR, FEATURED, MODERATOR]) {
            id
            category { ...categoryProps }
            createdAt updatedAt
            role
          }
        }
        """,
        needs: [tshirtProps, responsiveProps, categoryProps]
    )

    //|
    //|  REQUEST BODIES
    //|
    static let categoriesBody = Fragments(
        """
        id
        name
        slug
        description
        order
        allowInOnboarding
        isCreatorType
        level
        tileImage { ...tshirtProps }
        """,
        needs: [tshirtProps]
    )
    static let categoryAdminsBody = Fragments(
        """
        categoryUsers(roles: [CURATOR, MODERATOR]) {
            role user { ...authorProps }
        }
        """,
        needs: [authorProps]
    )
    static let pageHeaderBody = Fragments(
        """
        id
        postToken
        category { id }
        kind
        header
        subheader
        image { ...responsiveProps }
        ctaLink { text url }
        user { ...pageHeaderUserProps }
        """,
        needs: [responsiveProps, pageHeaderUserProps]
    )
    static let postStreamBody = Fragments(
        """
        next isLastPage
        posts {
            ...postDetails
        }
        """,
        needs: [postDetails]
    )
    static let commentStreamBody = Fragments(
        """
        next isLastPage
        comments {
            ...commentDetails
        }
        """,
        needs: [commentDetails]
    )
    static let postBody = Fragments(
        """
        ...postDetails
        """,
        needs: [postDetails]
    )
    static let userBody = Fragments(
        """
        ...userDetails
        """,
        needs: [userDetails]
    )
    static let loveStreamBody = Fragments(
        """
        next isLastPage
        loves {
            ...loveDetails
        }
        """,
        needs: [loveDetails]
    )

    let string: String
    let needs: [Fragments]

    var dependencies: [Fragments] {
        return (needs + needs.flatMap { $0.dependencies }).unique()
    }

    init(_ string: String, needs: [Fragments] = []) {
        self.string = string
        self.needs = needs
    }

    static func == (lhs: Fragments, rhs: Fragments) -> Bool {
        return lhs.string == rhs.string
    }
}
