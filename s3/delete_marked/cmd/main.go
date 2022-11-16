package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"

)

type client struct {
	Client     *s3.S3
	BucketName string
	PrefixName string
}

func (c client) ListBuckets() (*s3.ListBucketsOutput, error) {
	res, err := c.Client.ListBuckets(nil)
	if err != nil {
		return nil, err
	}

	return res, nil

}

func (c client) ListItems() (*s3.ListObjectsV2Output, error) {
	res, err := c.Client.ListObjectsV2(&s3.ListObjectsV2Input{
		Bucket: aws.String(c.BucketName),
		Prefix: aws.String(c.PrefixName),
	})

	if err != nil {
		return nil, err
	}

	return res, nil
}

func (c client) IsVersioningEnabled() bool {
	res, err := c.Client.GetBucketVersioning(&s3.GetBucketVersioningInput{Bucket: aws.String(c.BucketName)})

	if err != nil {
		fmt.Printf("Error checking bucket versioning %v", err)
		return false
	}

	return *res.Status == "Enabled"
}

func (c client) ListVersionedObjects() (*s3.ListObjectVersionsOutput, error) {
	res, err := c.Client.ListObjectVersions(&s3.ListObjectVersionsInput{
		Bucket: aws.String(c.BucketName),
		Prefix: aws.String(c.PrefixName),
	})

	if err != nil {
		return nil, err
	}

	return res, nil
}

func buildObjectIdentifier(markersEntry []*s3.DeleteMarkerEntry) []*s3.ObjectIdentifier {
	var objId []*s3.ObjectIdentifier
	for _, marker := range markersEntry {
		fmt.Printf("Key: %s VersionId: %s\n", *marker.Key, *marker.VersionId)
		objId = append(objId, &s3.ObjectIdentifier{
			Key:       marker.Key,
			VersionId: marker.VersionId,
		})
	}

	return objId
}

func (c client) DeleteObjectMarkers(markersEntry []*s3.DeleteMarkerEntry) (*s3.DeleteObjectsOutput, error) {
	objId := buildObjectIdentifier(markersEntry)

	res, err := c.Client.DeleteObjects(&s3.DeleteObjectsInput{
		Bucket: aws.String(c.BucketName),
		Delete: &s3.Delete{Objects: objId},
	})

	if err != nil {
		return nil, err
	}

	return res, nil
}

func NewClient(session *session.Session, bucketName string, prefixName string) *client {
	s3Client := s3.New(session)
	return &client{Client: s3Client, BucketName: bucketName, PrefixName: prefixName}
}

func main() {
	sess, err := session.NewSessionWithOptions(session.Options{
		Profile: "default",
		Config: aws.Config{
			Region: aws.String("eu-west-2"),
		},
	})

	if err != nil {
		fmt.Printf("Failed to initialize new session: %v", err)
	}

	bucketName := "hopin-test-jordi-casanella"
	prefixName := ""
	client := NewClient(sess, bucketName, prefixName)

	buckets, err := client.ListBuckets()
	if err != nil {
		fmt.Printf("Can not list buckets: %v", err)
		return
	}

	for _, bucket := range buckets.Buckets {
		fmt.Printf("Found bucket: %s, created at: %s\n", *bucket.Name, *bucket.CreationDate)
	}

	bucketObjects, err := client.ListItems()
	if err != nil {
		fmt.Printf("Could not retrieve bucket items: %v", err)
		return
	}

	for _, item := range bucketObjects.Contents {
		fmt.Printf("Name: %s Last Modified : %s\n", *item.Key, *item.LastModified)
	}

	if client.IsVersioningEnabled() {
		fmt.Printf("Bucket with version enabled\n")
		objectVersions, err := client.ListVersionedObjects()

		if err != nil {
			fmt.Printf("Could not retrieve versioned objects: %v", err)
			return
		}

		res, err := client.DeleteObjectMarkers(objectVersions.DeleteMarkers)
		if len(res.Deleted) != len(objectVersions.DeleteMarkers) {
			fmt.Printf("Some markers has not been removed\n")
		}
	} else {
		fmt.Printf("Bucket with version NOT enabled")
	}
}
